import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AkademikNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'akademik_queue_reminders',
    'Antrean Akademik',
    description:
        'Pengajuan, pengingat, pemanggilan, '
        'dan pembatalan antrean Akademik.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static const _events = {
    'ticket_created',
    'time_15',
    'time_5',
    'queue_8',
    'queue_4',
    'queue_called',
    'queue_cancelled',
  };

  static bool handles(Map<String, dynamic> data) {
    return data['module']?.toString().trim().toLowerCase() == 'akademik';
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

  static String? _key(Map<String, dynamic> data) {
    final id = int.tryParse(data['queue_ticket_id']?.toString() ?? '');

    final event = data['event']?.toString() ?? '';

    if (id == null || id <= 0 || !_events.contains(event)) {
      return null;
    }

    return 'akademik_${id}_$event';
  }

  static Future<void> rememberOpened(Map<String, dynamic> data) async {
    final key = _key(data);

    if (key != null) {
      await _prefs.setBool('shown_$key', true);
    }
  }

  static Future<void> display(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final data = message.data;

    final expiry = DateTime.tryParse(data['expires_at']?.toString() ?? '');

    if (expiry != null && !expiry.isAfter(DateTime.now())) {
      return;
    }

    final code = data['request_number']?.toString().trim() ?? '';

    final ticket = code.isEmpty ? 'tiket Akademik Anda' : code;

    final event = data['event']?.toString() ?? '';

    final ahead = int.tryParse(data['people_ahead']?.toString() ?? '');

    String? title;
    String? body;

    switch (event) {
      case 'time_15':
      case 'time_5':
        final minutes = event == 'time_15' ? 15 : 5;

        title = 'Pengingat Akademik: $minutes menit';
        body =
            'Giliran $ticket diperkirakan sekitar '
            '$minutes menit lagi. Silakan bersiap.';
        break;

      case 'queue_8':
      case 'queue_4':
        final remaining = ahead != null && ahead >= 0
            ? ahead
            : (event == 'queue_8' ? 8 : 4);

        title = 'Pengingat Akademik: $remaining orang';
        body =
            'Tersisa $remaining orang sebelum giliran '
            '$ticket. Silakan bersiap.';
        break;

      case 'queue_called':
        title = 'Antrean Akademik dipanggil';
        body =
            'Giliran $ticket telah tiba. '
            'Silakan menuju layanan Akademik.';
        break;

      case 'queue_cancelled':
        title = 'Antrean Akademik dibatalkan';

        final reason = data['cancellation_reason']?.toString().trim() ?? '';

        body =
            'Antrean $ticket dibatalkan. '
            '${reason.isEmpty ? 'Lihat alasan melalui Cek Status.' : 'Alasan: $reason'}';
        break;

      case 'ticket_created':
        title = 'Pengajuan tiket Akademik berhasil';
        body =
            'Tiket $ticket berhasil diajukan. '
            'Pantau giliran melalui Cek Status.';
        break;
    }

    title = message.notification?.title ?? title;
    body = message.notification?.body ?? body;

    if (title == null && body == null) {
      return;
    }

    await _show(
      plugin,
      data,
      title ?? 'Helpdesk POLNEP',
      body ?? '',
      fallbackTag:
          'akademik_fcm_'
          '${message.messageId ?? DateTime.now().microsecondsSinceEpoch}',
    );
  }

  static Future<void> showCreated(
    FlutterLocalNotificationsPlugin plugin, {
    required int ticketId,
    required String requestNumber,
    required String dateLabel,
    required String timeLabel,
  }) {
    return _show(
      plugin,
      {
        'module': 'akademik',
        'event': 'ticket_created',
        'queue_ticket_id': ticketId.toString(),
        'request_number': requestNumber,
      },
      'Pengajuan tiket Akademik berhasil',
      'Tiket $requestNumber berhasil diajukan.\n'
          'Tanggal antrean: $dateLabel\n'
          'Jam pilihan: $timeLabel\n'
          'Pantau giliran melalui Cek Status.',
    );
  }

  static Future<void> _show(
    FlutterLocalNotificationsPlugin plugin,
    Map<String, dynamic> data,
    String title,
    String body, {
    String? fallbackTag,
  }) async {
    final key = _key(data);

    if (key != null && await _prefs.getBool('shown_$key') == true) {
      return;
    }

    await plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'ic_stat_ult',
          importance: Importance.high,
          priority: Priority.high,
          tag:
              key ??
              fallbackTag ??
              'akademik_${DateTime.now().microsecondsSinceEpoch}',
          onlyAlertOnce: true,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: jsonEncode(data),
    );

    if (key != null) {
      await _prefs.setBool('shown_$key', true);
    }
  }
}
