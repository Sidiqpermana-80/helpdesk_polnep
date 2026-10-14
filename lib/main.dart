import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'services/ult_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final UltNotificationService notifications = UltNotificationService.instance;

  if (notifications.supported) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(ultFirebaseBackgroundHandler);

      await notifications.initialize();
    } catch (error) {
      debugPrint('Firebase/ULT notification setup error: $error');
    }
  }

  runApp(const HelpdeskPolnepApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifications.openPendingNotification();

    unawaited(_requestNotificationPermission());
  });
}

Future<void> _requestNotificationPermission() async {
  try {
    await UltNotificationService.instance.enableNotifications();
  } catch (error) {
    debugPrint('ULT notification permission error: $error');
  }
}

class HelpdeskPolnepApp extends StatelessWidget {
  const HelpdeskPolnepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: UltNotificationService.instance.navigatorKey,
      title: 'Helpdesk POLNEP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6268E8)),
      ),
      home: const WelcomePage(),
    );
  }
}
