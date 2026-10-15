import 'dart:async';
import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ult_device_sync_service.dart';
import '../firebase_options.dart';
import '../pages/cek_status/cek_status_page.dart';

// =========================================================
// JENIS PENGINGAT ULT
// =========================================================

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

// =========================================================
// CHANNEL NOTIFIKASI ANDROID
// =========================================================

const AndroidNotificationChannel _ultChannel = AndroidNotificationChannel(
  'ult_queue_reminders',
  'Pengingat Antrian ULT',
  description: 'Pengingat waktu dan jumlah orang sebelum giliran ULT.',
  importance: Importance.high,
);

// =========================================================
// DATA PESAN PENGINGAT
// =========================================================

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

  String get title {
    if (kind.isTime) {
      return 'Pengingat ULT: ${kind.threshold} menit';
    }

    return 'Pengingat ULT: ${peopleAhead ?? kind.threshold} orang';
  }

  String get body {
    if (kind.isTime) {
      return 'Giliran $requestNumber diperkirakan sekitar '
          '${kind.threshold} menit lagi. Silakan bersiap.';
    }

    return 'Tersisa ${peopleAhead ?? kind.threshold} orang '
        'sebelum giliran $requestNumber. Silakan bersiap.';
  }

  static _UltAlert? fromData(Map<String, dynamic> data) {
    UltReminderKind? kind;

    for (final UltReminderKind item in UltReminderKind.values) {
      if (item.code == data['event']?.toString()) {
        kind = item;
        break;
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

// =========================================================
// PERSIAPAN NOTIFIKASI LOKAL
// =========================================================

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

// =========================================================
// MENAMPILKAN PESAN
// =========================================================

Future<void> _displayMessage(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin plugin,
) async {
  final _UltAlert? alert = _UltAlert.fromData(message.data);

  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  if (alert != null) {
    final DateTime? expiry = alert.expiresAt;

    if (expiry != null && !expiry.isAfter(DateTime.now())) {
      return;
    }

    final bool alreadyShown =
        await prefs.getBool('shown_${alert.key}') ?? false;

    if (alreadyShown) {
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

// =========================================================
// HANDLER BACKGROUND
// =========================================================

@pragma('vm:entry-point')
Future<void> ultFirebaseBackgroundHandler(RemoteMessage message) async {
  // Pesan notification ditampilkan Android ketika di background.
  // Hindari menampilkannya lagi melalui notifikasi lokal.
  if (message.notification != null) {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();

  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  await _prepareLocalNotifications(plugin);

  await _displayMessage(message, plugin);
}

// =========================================================
// LAYANAN NOTIFIKASI ULT
// =========================================================

class UltNotificationService with WidgetsBindingObserver {
  UltNotificationService._();

  static final UltNotificationService instance = UltNotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final ValueNotifier<String?> token = ValueNotifier<String?>(null);

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  final ValueNotifier<String?> _statusKeyword = ValueNotifier<String?>(null);

  bool _initialized = false;
  bool _permissionAllowed = false;

  bool _pendingOpen = false;
  bool _statusPageOpen = false;

  String? _pendingRequestNumber;

  int _tokenGeneration = 0;

  DateTime? _nextTokenRefreshAt;

  Future<String?>? _tokenCycle;
  Future<String?>? _nativeTokenRequest;
  Future<bool>? _permissionRequest;

  Future<void> _foregroundQueue = Future<void>.value();

  bool get supported {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  // =======================================================
  // INITIALIZE
  // =======================================================

  Future<void> initialize() async {
    if (!supported || _initialized) {
      return;
    }

    await _prepareLocalNotifications(
      _local,
      onTap: (NotificationResponse response) {
        final String? requestNumber = _rememberOpenedPayload(response.payload);

        _requestOpen(requestNumber);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Proses pesan foreground secara berurutan.
      _foregroundQueue = _foregroundQueue
          .then((_) => _displayMessage(message, _local))
          .catchError((Object error, StackTrace stack) {
            debugPrint('ULT notification display error: $error');
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final String? requestNumber = _rememberOpenedPayload(
        jsonEncode(message.data),
      );

      _requestOpen(requestNumber);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String value) {
        unawaited(_handleTokenRefresh(value));
      },
      onError: (Object error) {
        debugPrint('ULT token refresh error: $error');
      },
    );

    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Notifikasi Firebase yang membuka aplikasi saat tertutup.
    try {
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initial != null) {
        _pendingRequestNumber = _rememberOpenedPayload(
          jsonEncode(initial.data),
        );

        _pendingOpen = true;
      }
    } catch (error) {
      debugPrint('ULT Firebase launch error: $error');
    }

    // Notifikasi lokal yang membuka aplikasi saat tertutup.
    try {
      final NotificationAppLaunchDetails? launch = await _local
          .getNotificationAppLaunchDetails();

      if (launch?.didNotificationLaunchApp == true) {
        _pendingRequestNumber = _rememberOpenedPayload(
          launch?.notificationResponse?.payload,
        );

        _pendingOpen = true;
      }
    } catch (error) {
      debugPrint('ULT local notification launch error: $error');
    }
  }

  // =======================================================
  // APLIKASI KEMBALI AKTIF
  // =======================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_initialized && state == AppLifecycleState.resumed) {
      // Memeriksa ulang tanpa menampilkan dialog izin lagi.
      unawaited(tokenForSubmission());
    }
  }

  Future<void> showTicketCreated({
    required int ticketId,
    required String requestNumber,
    String queueDateLabel = '',
    String queueTimeLabel = '',
  }) {
    if (!supported ||
        !_initialized ||
        !_permissionAllowed ||
        ticketId <= 0 ||
        requestNumber.trim().isEmpty) {
      return Future<void>.value();
    }

    _foregroundQueue = _foregroundQueue
        .then<void>((_) async {
          final String tag = 'ult_${ticketId}_ticket_created';

          final String preferenceKey = 'shown_$tag';

          // Konfirmasi untuk tiket yang sama cukup ditampilkan sekali.
          if (await _prefs.getBool(preferenceKey) == true) {
            return;
          }

          final String number = requestNumber.trim();
          final String date = queueDateLabel.trim();
          final String time = queueTimeLabel.trim();

          final String body = [
            'Tiket $number berhasil diajukan.',
            if (date.isNotEmpty) 'Tanggal antrean: $date',
            if (time.isNotEmpty) 'Jam pilihan: $time',
            'Pantau giliran melalui Cek Status.',
          ].join('\n');

          await _local.show(
            id: 0,
            title: 'Pengajuan tiket ULT berhasil',
            body: body,

            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _ultChannel.id,
                _ultChannel.name,
                channelDescription: _ultChannel.description,
                icon: 'ic_stat_ult',
                importance: Importance.high,
                priority: Priority.high,

                // Tag berbeda dari empat pengingat antrean.
                tag: tag,
                onlyAlertOnce: true,

                styleInformation: BigTextStyleInformation(body),
              ),
            ),

            payload: jsonEncode({
              'event': 'ticket_created',
              'queue_ticket_id': ticketId.toString(),
              'request_number': number,
            }),
          );

          await _prefs.setBool(preferenceKey, true);
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint('ULT ticket confirmation error: ${error.runtimeType}');
        });

    return _foregroundQueue;
  }

  // =======================================================
  // IZIN NOTIFIKASI
  // =======================================================

  Future<bool> enableNotifications() {
    if (!_initialized) {
      return Future<bool>.value(false);
    }

    final Future<bool>? active = _permissionRequest;

    if (active != null) {
      return active;
    }

    final Future<bool> request = _enableNotifications();

    _permissionRequest = request;

    unawaited(
      request.then<void>((_) {
        if (identical(_permissionRequest, request)) {
          _permissionRequest = null;
        }
      }),
    );

    return request;
  }

  Future<bool> _enableNotifications() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings()
          .timeout(const Duration(seconds: 5));

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

      _setPermission(settings);

      if (!_permissionAllowed) {
        return false;
      }

      // Pengambilan token berlangsung di belakang.
      unawaited(_startTokenRefresh());

      return true;
    } catch (error) {
      debugPrint('ULT notification permission error: $error');

      return false;
    }
  }

  bool _allowed(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  void _setPermission(NotificationSettings settings) {
    _permissionAllowed = _allowed(settings);

    if (!_permissionAllowed) {
      token.value = null;
      _nextTokenRefreshAt = null;
    }
  }

  // =======================================================
  // TOKEN BERUBAH DARI FIREBASE
  // =======================================================

  Future<void> _handleTokenRefresh(String value) async {
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .getNotificationSettings()
          .timeout(const Duration(seconds: 5));

      _setPermission(settings);

      if (_permissionAllowed) {
        _storeToken(value);
      }
    } catch (error) {
      debugPrint('ULT refreshed token permission error: $error');
    }
  }

  void _storeToken(String value) {
    final clean = value.trim();

    if (clean.isEmpty) {
      return;
    }

    token.value = clean;

    _tokenGeneration++;

    _nextTokenRefreshAt = DateTime.now().add(const Duration(minutes: 1));

    if (kDebugMode) {
      debugPrint('ULT FCM TOKEN: $clean');
    }

    unawaited(UltDeviceSyncService.instance.syncToken(clean));
  }

  // =======================================================
  // TOKEN UNTUK PENGIRIMAN FORM
  // =======================================================

  Future<String?> tokenForSubmission() async {
    if (!_initialized) {
      return null;
    }

    try {
      // Form tidak menunggu seluruh rangkaian percobaan ulang.
      return await _tokenForSubmission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (error) {
      debugPrint('ULT submission token error: $error');

      return null;
    }
  }

  Future<String?> _tokenForSubmission() async {
    final settings = await FirebaseMessaging.instance
        .getNotificationSettings()
        .timeout(const Duration(seconds: 5));

    _setPermission(settings);

    if (!_permissionAllowed) {
      return null;
    }

    final String? availableToken = token.value;

    if (availableToken != null) {
      unawaited(UltDeviceSyncService.instance.syncToken(availableToken));
    }

    final Future<String?> refresh = _startTokenRefresh();

    return token.value ?? await refresh;
  }

  // =======================================================
  // SATU SIKLUS PENGAMBILAN TOKEN
  // =======================================================

  Future<String?> _startTokenRefresh() {
    final Future<String?>? active = _tokenCycle;

    if (active != null) {
      return active;
    }

    final DateTime? next = _nextTokenRefreshAt;

    if (next != null && DateTime.now().isBefore(next)) {
      return Future<String?>.value(token.value);
    }

    final Future<String?> request = _fetchTokenWithRetry();

    _tokenCycle = request;

    unawaited(
      request.then<void>((_) {
        if (identical(_tokenCycle, request)) {
          _tokenCycle = null;
        }
      }),
    );

    return request;
  }

  // =======================================================
  // MAKSIMAL TIGA PERCOBAAN
  // =======================================================

  Future<String?> _fetchTokenWithRetry() async {
    const List<Duration> delays = [
      Duration.zero,
      Duration(seconds: 5),
      Duration(seconds: 15),
    ];

    final int generation = _tokenGeneration;

    for (int attempt = 0; attempt < delays.length; attempt++) {
      try {
        if (delays[attempt] != Duration.zero) {
          await Future<void>.delayed(delays[attempt]);
        }

        final NotificationSettings settings = await FirebaseMessaging.instance
            .getNotificationSettings()
            .timeout(const Duration(seconds: 5));

        _setPermission(settings);

        if (!_permissionAllowed) {
          return null;
        }

        // Token mungkin sudah datang ketika sedang menunggu.
        if (_tokenGeneration != generation && token.value != null) {
          return token.value;
        }

        final String? value = await _getNativeToken().timeout(
          const Duration(seconds: 8),
        );

        if (value != null && value.trim().isNotEmpty) {
          return value;
        }

        throw StateError('Token FCM belum tersedia.');
      } catch (error) {
        debugPrint('ULT token attempt ${attempt + 1}/3 gagal: $error');
      }
    }

    // Siklus berikutnya baru boleh dimulai setelah satu menit.
    _nextTokenRefreshAt = DateTime.now().add(const Duration(minutes: 1));

    debugPrint('ULT token: percobaan dihentikan sementara.');

    return token.value;
  }

  // =======================================================
  // CEGAH PERMINTAAN NATIVE BERSAMAAN
  // =======================================================

  Future<String?> _getNativeToken() {
    final Future<String?>? active = _nativeTokenRequest;

    if (active != null) {
      return active;
    }

    // Timeout Dart tidak membatalkan operasi Firebase native.
    // Gunakan operasi yang sama sampai operasi tersebut selesai.
    final Future<String?> request = FirebaseMessaging.instance.getToken().then((
      String? value,
    ) {
      if (!_permissionAllowed) {
        return null;
      }

      if (value != null && value.trim().isNotEmpty) {
        _storeToken(value);
      }

      return value;
    });

    _nativeTokenRequest = request;

    unawaited(
      request.then<void>(
        (_) {
          if (identical(_nativeTokenRequest, request)) {
            _nativeTokenRequest = null;
          }
        },
        onError: (Object error, StackTrace stack) {
          if (identical(_nativeTokenRequest, request)) {
            _nativeTokenRequest = null;
          }
        },
      ),
    );

    return request;
  }

  // =======================================================
  // DATA SAAT NOTIFIKASI DITEKAN
  // =======================================================

  String? _rememberOpenedPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final _UltAlert? alert = _UltAlert.fromData(decoded);

      if (alert != null) {
        unawaited(
          _prefs.setBool('shown_${alert.key}', true).catchError((Object error) {
            debugPrint('ULT remember notification error: $error');
          }),
        );
      }

      final String number = decoded['request_number']?.toString().trim() ?? '';

      return number.isEmpty ? null : number;
    } catch (error) {
      debugPrint('ULT notification payload error: $error');

      return null;
    }
  }

  void _requestOpen(String? requestNumber) {
    _pendingRequestNumber = requestNumber;
    _pendingOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      openPendingNotification();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  // =======================================================
  // BUKA CEK STATUS
  // =======================================================

  void openPendingNotification() {
    if (!_pendingOpen) {
      return;
    }

    final NavigatorState? navigator = navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    final String? number = _pendingRequestNumber;

    _pendingOpen = false;
    _pendingRequestNumber = null;

    if (_statusPageOpen) {
      if (number != null && number.isNotEmpty) {
        // Perbarui kode pada halaman Cek Status yang sudah terbuka.
        _statusKeyword.value = null;
        _statusKeyword.value = number;
      }

      return;
    }

    _statusPageOpen = true;

    unawaited(
      navigator
          .push<void>(
            MaterialPageRoute<void>(
              builder: (_) => CekStatusPage(
                initialKeyword: number ?? '',
                notificationKeyword: _statusKeyword,
              ),
            ),
          )
          .whenComplete(() {
            _statusPageOpen = false;
          }),
    );
  }
}
