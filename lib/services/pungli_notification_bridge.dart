import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PungliNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'pungli_complaints',
    'Pengaduan Pungli',
    description: 'Pengajuan berhasil, laporan diterima, dan laporan ditolak.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static bool handles(Map<String, dynamic> data) {
    return data['module'] == 'pengaduan_pungli';
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
    final notice = _PungliNotice.fromData(data);

    if (notice == null) {
      return;
    }

    await _prefs.setBool(notice.shownKey, true);
  }

  static Future<void> display(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final notice = _PungliNotice.fromData(message.data);

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
    final notice = _PungliNotice.fromData({
      'module': 'pengaduan_pungli',
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
    _PungliNotice notice,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (notice.expiresAt != null &&
        !notice.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    final shownKey = notice.shownKey;

    if (await _prefs.getBool(shownKey) == true) {
      debugPrint('PUNGLI_NOTIF: event sudah tercatat, dilewati.');
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
        'module': 'pengaduan_pungli',
        'event': notice.event,
        'request_id': notice.ticketId.toString(),
        'request_number': notice.requestNumber,
      }),
    );

    await _prefs.setBool(shownKey, true);

    debugPrint('PUNGLI_NOTIF: permintaan tampilan dikirim ke Android.');
  }
}

class _PungliNotice {
  const _PungliNotice({
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

  static _PungliNotice? fromData(Map<String, dynamic> data) {
    if (!PungliNotificationBridge.handles(data)) {
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

    return _PungliNotice(
      ticketId: id,
      requestNumber: number,
      event: event,
      expiresAt: expires,
    );
  }

  String get tag => 'pungli_${ticketId}_$event';

  String get shownKey =>
      'shown_pungli_${ticketId}_'
      '${Uri.encodeComponent(requestNumber)}_$event';

  String get title {
    switch (event) {
      case 'ticket_created':
        return 'Laporan berhasil dikirim';

      case 'report_accepted':
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
        return 'Laporan Anda berhasil dikirim dan '
            'menunggu verifikasi. Simpan kode tiket '
            'untuk memantau status laporan.';

      case 'report_accepted':
        return 'Laporan Anda telah diverifikasi dan '
            'diterima petugas. Periksa statusnya '
            'melalui Cek Status.';

      case 'report_rejected':
        return 'Laporan Anda ditolak oleh petugas. '
            'Periksa statusnya melalui Cek Status.';

      default:
        return '';
    }
  }
}
