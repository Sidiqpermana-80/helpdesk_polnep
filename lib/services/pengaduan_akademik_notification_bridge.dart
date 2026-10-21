import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaduanAkademikNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'academic_complaints',
    'Pengaduan Akademik',
    description: 'Pengajuan berhasil, laporan diterima, dan laporan ditolak.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static bool handles(Map<String, dynamic> data) {
    return data['module'] == 'pengaduan_akademik';
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
    final notice = _AcademicComplaintNotice.fromData(data);

    if (notice == null) {
      return;
    }

    await _prefs.setBool(notice.shownKey, true);
  }

  static Future<void> display(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final notice = _AcademicComplaintNotice.fromData(message.data);

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
    final notice = _AcademicComplaintNotice.fromData({
      'module': 'pengaduan_akademik',
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
    _AcademicComplaintNotice notice,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (notice.expiresAt != null &&
        !notice.expiresAt!.isAfter(DateTime.now())) {
      return;
    }

    final shownKey = notice.shownKey;

    if (await _prefs.getBool(shownKey) == true) {
      debugPrint(
        'PENGADUAN_AKADEMIK_NOTIF: '
        'event sudah tercatat, dilewati.',
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
        'module': 'pengaduan_akademik',
        'event': notice.event,
        'request_id': notice.ticketId.toString(),
        'request_number': notice.requestNumber,
      }),
    );

    await _prefs.setBool(shownKey, true);

    debugPrint(
      'PENGADUAN_AKADEMIK_NOTIF: '
      'permintaan tampilan dikirim ke Android.',
    );
  }
}

class _AcademicComplaintNotice {
  const _AcademicComplaintNotice({
    required this.ticketId,
    required this.requestNumber,
    required this.event,
    required this.rejectionReason,
    this.expiresAt,
  });

  final int ticketId;
  final String requestNumber;
  final String event;
  final String rejectionReason;
  final DateTime? expiresAt;

  static const _allowedEvents = <String>{
    'ticket_created',
    'report_accepted',
    'report_rejected',
  };

  static _AcademicComplaintNotice? fromData(Map<String, dynamic> data) {
    if (!PengaduanAkademikNotificationBridge.handles(data)) {
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

    final reason = data['rejection_reason'] is String
        ? (data['rejection_reason'] as String).trim()
        : '';

    final shortReason = String.fromCharCodes(reason.runes.take(240));

    return _AcademicComplaintNotice(
      ticketId: id,
      requestNumber: number,
      event: event,
      rejectionReason: reason.runes.length > 240
          ? '$shortReason…'
          : shortReason,
      expiresAt: expires,
    );
  }

  String get tag => 'academic_complaint_${ticketId}_$event';

  String get shownKey =>
      'shown_academic_complaint_${ticketId}_'
      '${Uri.encodeComponent(requestNumber)}_$event';

  String get title {
    switch (event) {
      case 'ticket_created':
        return 'Pengaduan Akademik berhasil dikirim';

      case 'report_accepted':
        return 'Laporan Akademik diterima';

      case 'report_rejected':
        return 'Laporan Akademik ditolak';

      default:
        return 'Pengaduan Akademik';
    }
  }

  String get body {
    switch (event) {
      case 'ticket_created':
        return 'Tiket $requestNumber berhasil dikirim dan '
            'menunggu verifikasi. Pantau perkembangannya '
            'melalui Cek Status.';

      case 'report_accepted':
        return 'Laporan $requestNumber telah diverifikasi '
            'dan diterima petugas. Periksa status laporan '
            'melalui Cek Status.';

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
