import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WifiNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'wifi_complaints',
    'Pengaduan Wi-Fi / Internet',
    description: 'Pengajuan berhasil, laporan selesai, dan laporan ditolak.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static bool handles(Map<String, dynamic> data) {
    return data['module'] == 'wifi_internet';
  }

  static Future<void> createChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> rememberOpened(Map<String, dynamic> data) async {
    final notice = _WifiNotice.fromData(data);

    if (notice == null) {
      return;
    }

    await _prefs.setBool(notice.shownKey, true);
  }

  static Future<void> display(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final notice = _WifiNotice.fromData(message.data);

    if (notice == null) {
      return;
    }

    await _show(notice, plugin);
  }

  static Future<void> showCreated({
    required FlutterLocalNotificationsPlugin plugin,
    required int ticketId,
    required String requestNumber,
    required bool isAccess,
  }) async {
    final notice = _WifiNotice.fromData({
      'module': 'wifi_internet',
      'event': 'ticket_created',
      'request_id': ticketId.toString(),
      'request_number': requestNumber.trim(),
      'request_kind': isAccess ? 'access' : 'network',
    });

    if (notice == null) {
      return;
    }

    await _show(notice, plugin);
  }

  static Future<void> _show(
    _WifiNotice notice,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (notice.expiresAt != null &&
        !notice.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    final shownKey = notice.shownKey;

    if (await _prefs.getBool(shownKey) == true) {
      debugPrint(
        'WIFI_NOTIF: dilewati karena notifikasi tiket ini '
        'sudah tercatat pernah ditampilkan.',
      );
      return;
    }

    await createChannel(plugin);

    await plugin.show(
      id: 0,
      title: notice.title,
      body: notice.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'ic_stat_ult',
          importance: Importance.high,
          priority: Priority.high,
          tag: notice.tag,
          onlyAlertOnce: true,
          styleInformation: BigTextStyleInformation(notice.body),
        ),
      ),
      payload: jsonEncode({
        'module': 'wifi_internet',
        'event': notice.event,
        'request_id': notice.ticketId.toString(),
        'request_number': notice.requestNumber,
      }),
    );

    await _prefs.setBool(shownKey, true);

    debugPrint('WIFI_NOTIF: permintaan tampilan sudah dikirim ke Android.');
  }
}

class _WifiNotice {
  const _WifiNotice({
    required this.ticketId,
    required this.requestNumber,
    required this.event,
    required this.isAccess,
    required this.rejectionReason,
    this.expiresAt,
  });

  final int ticketId;
  final String requestNumber;
  final String event;
  final bool isAccess;
  final String rejectionReason;
  final DateTime? expiresAt;

  static const _allowedEvents = <String>{
    'ticket_created',
    'report_completed',
    'report_rejected',
  };

  static _WifiNotice? fromData(Map<String, dynamic> data) {
    if (!WifiNotificationBridge.handles(data)) {
      return null;
    }

    final event = data['event']?.toString() ?? '';

    // Notifikasi diterima petugas / diproses tidak ditampilkan.
    if (!_allowedEvents.contains(event)) {
      return null;
    }

    final id = int.tryParse(data['request_id']?.toString() ?? '');

    final number = data['request_number']?.toString().trim() ?? '';

    if (id == null || id <= 0 || number.isEmpty) {
      return null;
    }

    final rawExpiry = data['expires_at']?.toString().trim() ?? '';

    final expires = rawExpiry.isEmpty ? null : DateTime.tryParse(rawExpiry);

    if (rawExpiry.isNotEmpty && expires == null) {
      return null;
    }

    final reason = data['rejection_reason'] is String
        ? (data['rejection_reason'] as String).trim()
        : '';

    final shortReason = String.fromCharCodes(reason.runes.take(240));

    return _WifiNotice(
      ticketId: id,
      requestNumber: number,
      event: event,
      isAccess: data['request_kind'] == 'access',
      rejectionReason: reason.runes.length > 240
          ? '$shortReason…'
          : shortReason,
      expiresAt: expires,
    );
  }

  String get tag => 'wifi_${ticketId}_$event';

  String get shownKey {
    if (event == 'ticket_created') {
      final numberKey = Uri.encodeComponent(requestNumber);

      return 'shown_wifi_created_${ticketId}_$numberKey';
    }

    return 'shown_$tag';
  }

  String get title {
    switch (event) {
      case 'ticket_created':
        return isAccess
            ? 'Akses Login/Wi-Fi berhasil diajukan'
            : 'Gangguan Jaringan berhasil dilaporkan';

      case 'report_completed':
        return 'Laporan Wi-Fi / Internet selesai';

      case 'report_rejected':
        return 'Laporan Wi-Fi / Internet ditolak';

      default:
        return 'Pengaduan Wi-Fi / Internet';
    }
  }

  String get body {
    switch (event) {
      case 'ticket_created':
        return 'Tiket $requestNumber berhasil dikirim dan '
            'menunggu verifikasi. Pantau perkembangannya '
            'melalui Cek Status.';

      case 'report_completed':
        return 'Tiket $requestNumber telah selesai ditangani '
            'petugas. Silakan periksa kembali layanan '
            'Wi-Fi / Internet Anda.';

      case 'report_rejected':
        if (rejectionReason.isNotEmpty) {
          return 'Tiket $requestNumber ditolak. '
              'Alasan: $rejectionReason';
        }

        return 'Tiket $requestNumber ditolak oleh petugas. '
            'Periksa status laporan Anda melalui Cek Status.';

      default:
        return '';
    }
  }
}
