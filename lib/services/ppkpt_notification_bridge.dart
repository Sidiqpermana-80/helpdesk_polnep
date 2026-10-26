import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PpkptNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'kampus_aman_complaints',
    'PPKPT',
    description: 'Pengajuan berhasil, laporan diterima, dan laporan ditolak.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static bool handles(Map<String, dynamic> data) {
    return data['module'] == 'kampus_aman';
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
    final notice = _PpkptNotice.fromData(data);

    if (notice == null) {
      return;
    }

    await _prefs.setBool(notice.shownKey, true);
  }

  static Future<void> display(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final notice = _PpkptNotice.fromData(message.data);

    if (notice == null) {
      return;
    }

    await _show(notice, plugin);
  }

  static Future<void> showCreated({
    required FlutterLocalNotificationsPlugin plugin,
    required int ticketId,
    required String requestNumber,
  }) async {
    final notice = _PpkptNotice.fromData({
      'module': 'kampus_aman',
      'event': 'ticket_created',
      'request_id': ticketId.toString(),
      'request_number': requestNumber.trim(),
    });

    if (notice == null) {
      return;
    }

    await _show(notice, plugin);
  }

  static Future<void> _show(
    _PpkptNotice notice,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (notice.expiresAt != null &&
        !notice.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    if (await _prefs.getBool(notice.shownKey) == true) {
      debugPrint('KAMPUS_AMAN_NOTIF: event sudah tercatat, dilewati.');

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
        'module': 'kampus_aman',
        'event': notice.event,
        'request_id': notice.ticketId.toString(),
        'request_number': notice.requestNumber,
      }),
    );

    await _prefs.setBool(notice.shownKey, true);

    debugPrint('KAMPUS_AMAN_NOTIF: permintaan tampilan dikirim ke Android.');
  }
}

class _PpkptNotice {
  const _PpkptNotice({
    required this.ticketId,
    required this.requestNumber,
    required this.event,
    this.expiresAt,
  });

  final int ticketId;
  final String requestNumber;
  final String event;
  final DateTime? expiresAt;

  static const _allowedEvents = <String>{
    'ticket_created',
    'report_accepted',
    'report_rejected',
  };

  static _PpkptNotice? fromData(Map<String, dynamic> data) {
    if (!PpkptNotificationBridge.handles(data)) {
      return null;
    }

    final event = data['event']?.toString() ?? '';

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

    return _PpkptNotice(
      ticketId: id,
      requestNumber: number,
      event: event,
      expiresAt: expires,
    );
  }

  String get tag => 'kampus_aman_${ticketId}_$event';

  String get shownKey =>
      'shown_kampus_aman_${ticketId}_'
      '${Uri.encodeComponent(requestNumber)}_$event';

  String get title {
    switch (event) {
      case 'ticket_created':
        return 'Laporan berhasil dikirim';

      case 'report_completed':
        return 'Laporan diterima';

      case 'report_rejected':
        return 'Laporan ditolak';

      default:
        return 'Informasi laporan';
    }
  }

  String get body {
    switch (event) {
      case 'ticket_created':
        return 'Laporan Anda berhasil dikirim dan menunggu '
            'verifikasi. Simpan kode tiket untuk memantau '
            'status laporan.';

      case 'report_accepted':
        return 'Laporan Anda telah diverifikasi dan diterima '
            'petugas untuk ditindaklanjuti. '
            'Periksa statusnya melalui Cek Status.';

      case 'report_rejected':
        return 'Laporan Anda ditolak oleh petugas. '
            'Periksa statusnya melalui Cek Status.';

      default:
        return '';
    }
  }
}
