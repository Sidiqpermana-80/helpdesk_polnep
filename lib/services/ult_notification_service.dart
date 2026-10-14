import 'dart:async';
import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../pages/cek_status/cek_status_page.dart';

// EMPAT JENIS PENGINGAT
enum UltReminderKind {
  time15('time_15', 15, true),
  time5('time_5', 5, true),
  queue8('queue_8', 8, false),
  queue4('queue_4', 4, false);

  const UltReminderKind(this.code, this.threshold, this.isTime);

  final String code;
  final int threshold;
  final bool isTime;
}

// CHANNEL NOTIFIKASI ANDROID
const AndroidNotificationChannel _ultChannel = AndroidNotificationChannel(
  'ult_queue_reminders',
  'Pengingat Antrian ULT',
  description: 'Pengingat waktu dan jumlah orang sebelum giliran ULT.',
  importance: Importance.high,
);

// DATA PENGINGAT
class _UltAlert {
  const _UltAlert(
    this.kind,
    this.ticketId,
    this.requestNumber,
    this.expiresAt,
    this.peopleAhead,
  );

  final UltReminderKind kind;
  final String ticketId;
  final String requestNumber;
  final DateTime? expiresAt;
  final int? peopleAhead;

  String get key => 'ult_${ticketId}_${kind.code}';

  String get title => kind.isTime
      ? 'Pengingat ULT: ${kind.threshold} menit'
      : 'Pengingat ULT: ${peopleAhead ?? kind.threshold} orang';

  String get body => kind.isTime
      ? 'Giliran $requestNumber diperkirakan sekitar '
            '${kind.threshold} menit lagi. Silakan bersiap.'
      : 'Tersisa ${peopleAhead ?? kind.threshold} orang '
            'sebelum giliran $requestNumber. Silakan bersiap.';

  static _UltAlert? fromData(Map<String, dynamic> data) {
    UltReminderKind? kind;

    for (final UltReminderKind item in UltReminderKind.values) {
      if (item.code == data['event']?.toString()) {
        kind = item;
      }
    }

    final String id = data['queue_ticket_id']?.toString() ?? '';

    if (kind == null || (int.tryParse(id) ?? 0) <= 0) {
      return null;
    }

    final String number = data['request_number']?.toString().trim() ?? '';

    final String expiry = data['expires_at']?.toString() ?? '';

    final int? remaining = int.tryParse(data['people_ahead']?.toString() ?? '');

    return _UltAlert(
      kind,
      id,
      number.isEmpty ? 'tiket ULT Anda' : number,
      expiry.isEmpty ? null : DateTime.tryParse(expiry),
      remaining != null && remaining >= 0 ? remaining : null,
    );
  }
}

// MENYIAPKAN PLUGIN NOTIFIKASI LOKAL
Future<void> _prepareLocalNotifications(
  FlutterLocalNotificationsPlugin plugin, {
  DidReceiveNotificationResponseCallback? onTap,
}) async {
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_ult'),
    ),
    onDidReceiveNotificationResponse: onTap,
  );

  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_ultChannel);
}

// MENAMPILKAN PESAN
Future<void> _displayMessage(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin plugin,
) async {
  final _UltAlert? alert = _UltAlert.fromData(message.data);

  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  if (alert != null) {
    // Abaikan pesan yang sudah kedaluwarsa.
    if (alert.expiresAt != null && !alert.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    // Membantu mencegah tampilan lokal berulang.
    if (await prefs.getBool('shown_${alert.key}') == true) {
      return;
    }
  }

  final String? title = message.notification?.title ?? alert?.title;

  final String? body = message.notification?.body ?? alert?.body;

  if (title == null && body == null) {
    return;
  }

  final String tag =
      alert?.key ??
      'fcm_${message.messageId ?? DateTime.now().microsecondsSinceEpoch}';

  await plugin.show(
    id: 0,
    title: title ?? 'Helpdesk POLNEP',
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _ultChannel.id,
        _ultChannel.name,
        channelDescription: _ultChannel.description,
        icon: 'ic_stat_ult',
        importance: Importance.high,
        priority: Priority.high,
        tag: tag,
        onlyAlertOnce: true,
        styleInformation: BigTextStyleInformation(body ?? ''),
      ),
    ),
    payload: jsonEncode(message.data),
  );

  if (alert != null) {
    await prefs.setBool('shown_${alert.key}', true);
  }
}

// HANDLER BACKGROUND HARUS BERADA DI LUAR CLASS
@pragma('vm:entry-point')
Future<void> ultFirebaseBackgroundHandler(RemoteMessage message) async {
  // Pesan notification + data ditampilkan Android otomatis
  // ketika aplikasi berada di background.
  // Hindari menampilkannya dua kali.
  if (message.notification != null) {
    return;
  }

  // Untuk pesan data-only.
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  await _prepareLocalNotifications(plugin);
  await _displayMessage(message, plugin);
}

class UltNotificationService {
  UltNotificationService._();

  static final UltNotificationService instance = UltNotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Perubahan token dapat digunakan untuk sinkronisasi
  // dengan Laravel pada tahap integrasi berikutnya.
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  bool _initialized = false;
  bool _pendingOpen = false;
  bool _statusPageOpen = false;

  Future<void> _foregroundQueue = Future<void>.value();

  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (!supported || _initialized) {
      return;
    }

    await _prepareLocalNotifications(
      _local,
      onTap: (NotificationResponse response) {
        _rememberOpenedPayload(response.payload);
        _requestOpen();
      },
    );

    // APLIKASI SEDANG TERBUKA
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Proses berurutan untuk menghindari dua pesan
      // berlomba membaca dan menulis penanda.
      _foregroundQueue = _foregroundQueue
          .then((_) => _displayMessage(message, _local))
          .catchError((Object error, StackTrace stack) {
            debugPrint('ULT notification display error: $error');
          });
    });

    // NOTIFIKASI DITEKAN DARI BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _rememberOpenedPayload(jsonEncode(message.data));

      _requestOpen();
    });

    // TOKEN PERANGKAT BERUBAH
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String value) {
        token.value = value;

        // Laravel nanti perlu menerima pembaruan token
        // untuk tiket aktif yang terkait perangkat ini.
        if (kDebugMode) {
          debugPrint('ULT FCM token diperbarui: $value');
        }
      },
      onError: (Object error) {
        debugPrint('ULT token refresh error: $error');
      },
    );

    _initialized = true;

    // APLIKASI DIBUKA DARI KONDISI TERTUTUP
    try {
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initial != null) {
        _rememberOpenedPayload(jsonEncode(initial.data));

        _pendingOpen = true;
      }

      final NotificationAppLaunchDetails? launch = await _local
          .getNotificationAppLaunchDetails();

      if (launch?.didNotificationLaunchApp == true) {
        _rememberOpenedPayload(launch?.notificationResponse?.payload);

        _pendingOpen = true;
      }
    } catch (error) {
      debugPrint('ULT notification launch error: $error');
    }
  }

  // MEMINTA IZIN NOTIFIKASI
  Future<bool> enableNotifications() async {
    if (!_initialized) {
      return false;
    }

    NotificationSettings settings = await FirebaseMessaging.instance
        .getNotificationSettings();

    final bool asked =
        await _prefs.getBool('ult_notification_permission_asked') ?? false;

    if (!_allowed(settings) && !asked) {
      await _prefs.setBool('ult_notification_permission_asked', true);

      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (!_allowed(settings)) {
      token.value = null;
      return false;
    }

    await tokenForSubmission();

    return true;
  }

  bool _allowed(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // TOKEN UNTUK DIKIRIM BERSAMA FORM ULT
  Future<String?> tokenForSubmission() async {
    if (!_initialized) {
      return null;
    }

    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings()
          .timeout(const Duration(seconds: 8));

      if (!_allowed(settings)) {
        token.value = null;
        return null;
      }

      final String? value = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 8),
      );

      if (value != null && value.isNotEmpty) {
        token.value = value;

        if (kDebugMode) {
          debugPrint('ULT FCM TOKEN: $value');
        }
      }
    } catch (error) {
      debugPrint('ULT get token error: $error');
    }

    return token.value;
  }

  void _rememberOpenedPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final dynamic data = jsonDecode(payload);

      if (data is! Map<String, dynamic>) {
        return;
      }

      final _UltAlert? alert = _UltAlert.fromData(data);

      if (alert == null) {
        return;
      }

      unawaited(
        _prefs.setBool('shown_${alert.key}', true).catchError((Object error) {
          debugPrint('ULT remember notification error: $error');
        }),
      );
    } catch (error) {
      debugPrint('ULT notification payload error: $error');
    }
  }

  void _requestOpen() {
    _pendingOpen = true;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => openPendingNotification(),
    );

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  // MEMBUKA CEK STATUS
  void openPendingNotification() {
    if (!_pendingOpen) {
      return;
    }

    final NavigatorState? navigator = navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    _pendingOpen = false;

    if (_statusPageOpen) {
      return;
    }

    _statusPageOpen = true;

    unawaited(
      navigator
          .push<void>(
            MaterialPageRoute<void>(builder: (_) => const CekStatusPage()),
          )
          .whenComplete(() => _statusPageOpen = false),
    );
  }
}
