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

import 'akademik_device_sync_service.dart';
import 'akademik_notification_bridge.dart';
import 'ult_device_sync_service.dart';

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
// CHANNEL ULT
// Channel Akademik dibuat melalui AkademikNotificationBridge.
// =========================================================

const AndroidNotificationChannel _ultChannel = AndroidNotificationChannel(
  'ult_queue_reminders',
  'Pengingat Antrian ULT',
  description: 'Pengingat waktu dan jumlah orang sebelum giliran ULT.',
  importance: Importance.high,
);

// =========================================================
// DATA PESAN PENGINGAT ULT
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

  String get key {
    return 'ult_${ticketId}_${kind.code}';
  }

  String get title {
    if (kind.isTime) {
      return 'Pengingat ULT: ${kind.threshold} menit';
    }

    return 'Pengingat ULT: '
        '${peopleAhead ?? kind.threshold} orang';
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
    // Pesan Akademik ditangani oleh bridge Akademik.
    if (AkademikNotificationBridge.handles(data)) {
      return null;
    }

    UltReminderKind? kind;

    for (final item in UltReminderKind.values) {
      if (item.code == data['event']?.toString()) {
        kind = item;
        break;
      }
    }

    final id = data['queue_ticket_id']?.toString() ?? '';

    if (kind == null || (int.tryParse(id) ?? 0) <= 0) {
      return null;
    }

    final number = data['request_number']?.toString().trim() ?? '';

    final expiry = data['expires_at']?.toString() ?? '';

    final remaining = int.tryParse(data['people_ahead']?.toString() ?? '');

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

  await AkademikNotificationBridge.createChannel(plugin);
}

// =========================================================
// MENAMPILKAN PESAN ULT ATAU AKADEMIK
// =========================================================

Future<void> _displayMessage(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (AkademikNotificationBridge.handles(message.data)) {
    await AkademikNotificationBridge.display(message, plugin);
    return;
  }

  final alert = _UltAlert.fromData(message.data);
  final prefs = SharedPreferencesAsync();

  if (alert != null) {
    if (alert.expiresAt != null && !alert.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    if (await prefs.getBool('shown_${alert.key}') == true) {
      return;
    }
  }

  final title = message.notification?.title ?? alert?.title;

  final body = message.notification?.body ?? alert?.body;

  if (title == null && body == null) {
    return;
  }

  final tag =
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
// BACKGROUND HANDLER BERSAMA
// =========================================================

@pragma('vm:entry-point')
Future<void> queueFirebaseBackgroundHandler(RemoteMessage message) async {
  // Pesan dengan notification ditampilkan Android otomatis
  // ketika aplikasi berada di background.
  if (message.notification != null) {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final plugin = FlutterLocalNotificationsPlugin();

  await _prepareLocalNotifications(plugin);
  await _displayMessage(message, plugin);
}

// =========================================================
// SERVICE NOTIFIKASI ANTREAN BERSAMA
// =========================================================

class QueueNotificationService with WidgetsBindingObserver {
  QueueNotificationService._();

  static final QueueNotificationService instance = QueueNotificationService._();

  Future<void> showKampusAmanCreated({required int ticketId}) {
    if (!supported || !_initialized || !_permissionAllowed || ticketId <= 0) {
      return Future<void>.value();
    }

    _foregroundQueue = _foregroundQueue
        .then<void>((_) async {
          const channel = AndroidNotificationChannel(
            'helpdesk_private_confirmations',
            'Konfirmasi Laporan',
            description: 'Konfirmasi pengiriman laporan.',
            importance: Importance.high,
          );

          await _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(channel);

          final tag = 'kampus_aman_${ticketId}_created';
          final key = 'shown_$tag';

          if (await _prefs.getBool(key) == true) {
            return;
          }

          await _local.show(
            id: 0,
            title: 'Laporan berhasil dikirim',
            body: 'Simpan kode tiket dan kunci akses di tempat pribadi.',
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'ic_stat_ult',
                importance: Importance.high,
                priority: Priority.high,
                tag: tag,
                onlyAlertOnce: true,
              ),
            ),
            payload: 'kampus_aman_confirmation',
          );

          await _prefs.setBool(key, true);
        })
        .catchError((Object error, StackTrace stack) {
          // Kegagalan notifikasi tidak membatalkan pengajuan.
        });

    return _foregroundQueue;
  }

  Future<void> showPungliTicketCreated({
    required int ticketId,
    required String requestNumber,
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
          const channel = AndroidNotificationChannel(
            'pungli_complaints',
            'Pengaduan Pungli',
            description: 'Konfirmasi pengajuan laporan Pungli.',
            importance: Importance.high,
          );

          await _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(channel);

          final tag = 'pungli_${ticketId}_created';
          final key = 'shown_$tag';

          if (await _prefs.getBool(key) == true) {
            return;
          }

          final number = requestNumber.trim();

          final body =
              'Laporan $number berhasil dikirim. '
              'Pantau verifikasi laporan melalui Cek Status.';

          await _local.show(
            id: 0,

            title: 'Laporan Pungli berhasil dikirim',

            body: body,

            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,

                icon: 'ic_stat_ult',

                importance: Importance.high,
                priority: Priority.high,

                tag: tag,

                onlyAlertOnce: true,

                styleInformation: BigTextStyleInformation(body),
              ),
            ),

            payload: jsonEncode({
              'module': 'pengaduan_pungli',
              'event': 'ticket_created',
              'request_id': ticketId.toString(),
              'request_number': number,
            }),
          );

          await _prefs.setBool(key, true);
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint('PUNGLI confirmation error: ${error.runtimeType}');
        });

    return _foregroundQueue;
  }

  Future<void> showAcademicComplaintCreated({
    required int ticketId,
    required String requestNumber,
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
          const channel = AndroidNotificationChannel(
            'academic_complaints',
            'Pengaduan Akademik',
            description: 'Konfirmasi pengajuan pengaduan Akademik.',
            importance: Importance.high,
          );

          await _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(channel);

          final tag = 'academic_complaint_${ticketId}_created';
          final key = 'shown_$tag';

          if (await _prefs.getBool(key) == true) {
            return;
          }

          final number = requestNumber.trim();

          final body =
              'Pengaduan $number berhasil dikirim. '
              'Pantau verifikasi laporan melalui Cek Status.';

          await _local.show(
            id: 0,
            title: 'Pengaduan Akademik berhasil dikirim',
            body: body,

            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'ic_stat_ult',
                importance: Importance.high,
                priority: Priority.high,
                tag: tag,
                onlyAlertOnce: true,
                styleInformation: BigTextStyleInformation(body),
              ),
            ),

            payload: jsonEncode({
              'module': 'pengaduan_akademik',
              'event': 'ticket_created',
              'request_id': ticketId.toString(),
              'request_number': number,
            }),
          );

          await _prefs.setBool(key, true);
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint(
            'ACADEMIC complaint confirmation error: '
            '${error.runtimeType}',
          );
        });

    return _foregroundQueue;
  }

  final navigatorKey = GlobalKey<NavigatorState>();

  final token = ValueNotifier<String?>(null);

  final _local = FlutterLocalNotificationsPlugin();
  final _prefs = SharedPreferencesAsync();

  final _statusKeyword = ValueNotifier<String?>(null);

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
        if (response.payload == 'kampus_aman_confirmation') {
          return;
        }

        _requestOpen(_rememberOpenedPayload(response.payload));
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundQueue = _foregroundQueue
          .then((_) => _displayMessage(message, _local))
          .catchError((Object error, StackTrace stack) {
            debugPrint('QUEUE notification display error: $error');
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _requestOpen(_rememberOpenedPayload(jsonEncode(message.data)));
    });

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String value) {
        unawaited(_handleTokenRefresh(value));
      },
      onError: (Object error) {
        debugPrint('FCM token refresh error: $error');
      },
    );

    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Pesan Firebase yang membuka aplikasi dari keadaan tertutup.
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();

      if (initial != null) {
        _pendingRequestNumber = _rememberOpenedPayload(
          jsonEncode(initial.data),
        );

        _pendingOpen = true;
      }
    } catch (error) {
      debugPrint('QUEUE Firebase launch error: $error');
    }

    // Notifikasi lokal yang membuka aplikasi dari keadaan tertutup.
    try {
      final launch = await _local.getNotificationAppLaunchDetails();

      if (launch?.didNotificationLaunchApp == true &&
          launch?.notificationResponse?.payload != 'kampus_aman_confirmation') {
        _pendingRequestNumber = _rememberOpenedPayload(
          launch?.notificationResponse?.payload,
        );

        _pendingOpen = true;
      }
    } catch (error) {
      debugPrint('QUEUE local notification launch error: $error');
    }
  }

  // =======================================================
  // APLIKASI KEMBALI AKTIF
  // =======================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_initialized && state == AppLifecycleState.resumed) {
      unawaited(tokenForSubmission());
    }
  }

  // =======================================================
  // KONFIRMASI PENGAJUAN ULT
  // Nama method dipertahankan untuk pemanggilan ULT.
  // =======================================================

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
          final tag = 'ult_${ticketId}_ticket_created';
          final preferenceKey = 'shown_$tag';

          if (await _prefs.getBool(preferenceKey) == true) {
            return;
          }

          final number = requestNumber.trim();
          final date = queueDateLabel.trim();
          final time = queueTimeLabel.trim();

          final body = [
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
  // KONFIRMASI PENGAJUAN AKADEMIK
  // =======================================================

  Future<void> showAcademicTicketCreated({
    required int ticketId,
    required String requestNumber,
    required String queueDateLabel,
    required String queueTimeLabel,
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
          await AkademikNotificationBridge.showCreated(
            _local,
            ticketId: ticketId,
            requestNumber: requestNumber,
            dateLabel: queueDateLabel,
            timeLabel: queueTimeLabel,
          );
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint(
            'AKADEMIK ticket confirmation error: '
            '${error.runtimeType}',
          );
        });

    return _foregroundQueue;
  }

  Future<void> showWifiTicketCreated({
    required int ticketId,
    required String requestNumber,
    required bool isAccess,
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
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'wifi_complaints',
            'Pengaduan Wi-Fi / Internet',
            description: 'Konfirmasi pengajuan Wi-Fi / Internet.',
            importance: Importance.high,
          );

          await _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(channel);

          final String tag = 'wifi_${ticketId}_ticket_created';

          final String preferenceKey = 'shown_$tag';

          if (await _prefs.getBool(preferenceKey) == true) {
            return;
          }

          final String number = requestNumber.trim();

          final String serviceName = isAccess
              ? 'Akses Login/Wi-Fi'
              : 'Gangguan Jaringan';

          final String body =
              'Tiket $number berhasil diajukan. '
              'Pantau tindak lanjut $serviceName melalui Cek Status.';

          await _local.show(
            id: 0,

            title: '$serviceName berhasil diajukan',

            body: body,

            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,

                icon: 'ic_stat_ult',

                importance: Importance.high,
                priority: Priority.high,

                tag: tag,

                onlyAlertOnce: true,

                styleInformation: BigTextStyleInformation(body),
              ),
            ),

            payload: jsonEncode({
              'module': 'wifi_internet',
              'event': 'ticket_created',
              'request_id': ticketId.toString(),
              'request_number': number,
            }),
          );

          await _prefs.setBool(preferenceKey, true);
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint('WIFI confirmation error: ${error.runtimeType}');
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

    final active = _permissionRequest;

    if (active != null) {
      return active;
    }

    final request = _enableNotifications();

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
      var settings = await FirebaseMessaging.instance
          .getNotificationSettings()
          .timeout(const Duration(seconds: 5));

      // Kunci lama dipertahankan agar riwayat permintaan izin
      // dari versi sebelumnya tetap terbaca.
      final asked =
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

      unawaited(_startTokenRefresh());

      return true;
    } catch (error) {
      debugPrint('FCM notification permission error: $error');

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
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings()
          .timeout(const Duration(seconds: 5));

      _setPermission(settings);

      if (_permissionAllowed) {
        _storeToken(value);
      }
    } catch (error) {
      debugPrint('FCM refreshed token permission error: $error');
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
      debugPrint('FCM TOKEN: $clean');
    }

    unawaited(UltDeviceSyncService.instance.syncToken(clean));

    unawaited(AkademikDeviceSyncService.instance.syncToken(clean));
  }

  // =======================================================
  // TOKEN UNTUK PENGIRIMAN FORM
  // =======================================================

  Future<String?> tokenForSubmission() async {
    if (!_initialized) {
      return null;
    }

    try {
      return await _tokenForSubmission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (error) {
      debugPrint('FCM submission token error: $error');

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

    final current = token.value;

    if (current != null) {
      unawaited(UltDeviceSyncService.instance.syncToken(current));

      unawaited(AkademikDeviceSyncService.instance.syncToken(current));
    }

    final refresh = _startTokenRefresh();

    return token.value ?? await refresh;
  }

  // =======================================================
  // SATU SIKLUS PENGAMBILAN TOKEN
  // =======================================================

  Future<String?> _startTokenRefresh() {
    final active = _tokenCycle;

    if (active != null) {
      return active;
    }

    final next = _nextTokenRefreshAt;

    if (next != null && DateTime.now().isBefore(next)) {
      return Future<String?>.value(token.value);
    }

    final request = _fetchTokenWithRetry();

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
  // MAKSIMAL TIGA PERCOBAAN PENGAMBILAN TOKEN
  // =======================================================

  Future<String?> _fetchTokenWithRetry() async {
    const delays = <Duration>[
      Duration.zero,
      Duration(seconds: 5),
      Duration(seconds: 15),
    ];

    final generation = _tokenGeneration;

    for (var attempt = 0; attempt < delays.length; attempt++) {
      try {
        if (delays[attempt] != Duration.zero) {
          await Future<void>.delayed(delays[attempt]);
        }

        final settings = await FirebaseMessaging.instance
            .getNotificationSettings()
            .timeout(const Duration(seconds: 5));

        _setPermission(settings);

        if (!_permissionAllowed) {
          return null;
        }

        // Token mungkin sudah datang dari onTokenRefresh
        // atau permintaan native sebelumnya.
        if (_tokenGeneration != generation && token.value != null) {
          return token.value;
        }

        final value = await _getNativeToken().timeout(
          const Duration(seconds: 8),
        );

        if (value != null && value.trim().isNotEmpty) {
          return value;
        }

        throw StateError('Token FCM belum tersedia.');
      } catch (error) {
        debugPrint('FCM token attempt ${attempt + 1}/3 gagal: $error');
      }
    }

    _nextTokenRefreshAt = DateTime.now().add(const Duration(minutes: 1));

    debugPrint('FCM token: percobaan dihentikan sementara.');

    return token.value;
  }

  // =======================================================
  // CEGAH PERMINTAAN NATIVE BERSAMAAN
  // =======================================================

  Future<String?> _getNativeToken() {
    final active = _nativeTokenRequest;

    if (active != null) {
      return active;
    }

    // Timeout Dart tidak membatalkan operasi native.
    // Gunakan operasi yang sama sampai selesai.
    final request = FirebaseMessaging.instance.getToken().then((value) {
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

      if (AkademikNotificationBridge.handles(decoded)) {
        unawaited(
          AkademikNotificationBridge.rememberOpened(decoded).catchError((
            Object error,
          ) {
            debugPrint(
              'AKADEMIK remember notification error: '
              '${error.runtimeType}',
            );
          }),
        );
      }

      final alert = _UltAlert.fromData(decoded);

      if (alert != null) {
        unawaited(
          _prefs.setBool('shown_${alert.key}', true).catchError((Object error) {
            debugPrint('ULT remember notification error: $error');
          }),
        );
      }

      final number = decoded['request_number']?.toString().trim() ?? '';

      return number.isEmpty ? null : number;
    } catch (error) {
      debugPrint('QUEUE notification payload error: $error');

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

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    final number = _pendingRequestNumber;

    _pendingOpen = false;
    _pendingRequestNumber = null;

    if (_statusPageOpen) {
      if (number != null && number.isNotEmpty) {
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
