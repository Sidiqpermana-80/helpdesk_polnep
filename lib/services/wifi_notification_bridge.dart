import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WifiNotificationBridge {
  static const channel = AndroidNotificationChannel(
    'wifi_complaints',
    'Pengaduan Wi-Fi / Internet',
    description: 'Konfirmasi dan pembaruan status pengaduan Wi-Fi.',
    importance: Importance.high,
  );

  static final _prefs = SharedPreferencesAsync();

  static bool handles(Map<String, dynamic> data) {
    return data['module'] == 'wifi_internet';
  }

  static String? _key(Map<String, dynamic> data) {
    final id = int.tryParse(data['request_id']?.toString() ?? '');

    final event = data['event']?.toString();

    if (id == null ||
        id <= 0 ||
        !['report_accepted', 'report_completed'].contains(event)) {
      return null;
    }

    return 'wifi_${id}_$event';
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
    final key = _key(data);

    if (key == null) {
      return;
    }

    final expires = DateTime.tryParse(data['expires_at']?.toString() ?? '');

    if (expires != null && !expires.isAfter(DateTime.now())) {
      return;
    }

    if (await _prefs.getBool('shown_$key') == true) {
      return;
    }

    final accepted = data['event'] == 'report_accepted';

    final number = data['request_number']?.toString().trim() ?? '';

    final title =
        message.notification?.title ??
        (accepted ? 'Laporan diterima petugas' : 'Laporan selesai ditangani');

    final body =
        message.notification?.body ??
        (accepted
            ? 'Tiket $number diterima petugas dan mulai diproses.'
            : 'Tiket $number selesai ditangani. '
                  'Periksa status melalui Cek Status.');

    await createChannel(plugin);

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
          tag: key,
          onlyAlertOnce: true,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: jsonEncode(data),
    );

    await _prefs.setBool('shown_$key', true);
  }
}
