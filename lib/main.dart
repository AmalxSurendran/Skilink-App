// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'package:customer/utils/api.dart';
import 'package:customer/view/screens/Onboboarding/onboarding_view.dart';
import 'package:customer/view/screens/LandingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:http/http.dart' as http;
import 'app/generalImports.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Ensure the app works only in portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: whiteColor));

  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;
  final facebookAppEvents = FacebookAppEvents();

  runApp(
    ProviderScope(
      child: MyApp(
        onboarding: onboarding,
        facebookAppEvents: facebookAppEvents,
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  final bool onboarding;
  final FacebookAppEvents facebookAppEvents;

  const MyApp({
    super.key,
    required this.onboarding,
    required this.facebookAppEvents,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeFirebaseMessaging();
    _getFcmToken();
    _requestPermissions();
  }

  // Initialize local notifications
  void _initializeNotifications() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsDarwin = const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Initialize Firebase Messaging
  void _initializeFirebaseMessaging() {
    FirebaseMessaging.instance.subscribeToTopic('daily');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message);
    });
  }

  // Handle incoming notifications
  void _handleNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      var notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }
  }

  // Request permissions for notifications
  void _requestPermissions() async {
    if (await Permission.notification.request().isGranted) {
      // Permission granted
    } else {
      // Handle permission denied
    }
  }

  // Get Firebase Cloud Messaging token and update SharedPreferences
  Future<void> _getFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final existingToken = prefs.getString('fcm_token');
      final customerId = prefs.getString('customer_id');

      if (existingToken == token) return;

      await prefs.setString('fcm_token', token);
      log('Updated FCM Token in SharedPreferences.');

      if (customerId != null) {
        await _updateTokenOnServer(customerId, token);
      }
    }
  }

  // API call to update FCM token on server
  Future<void> _updateTokenOnServer(String customerId, String token) async {
    final response = await http.patch(
      Uri.parse(Api.updateToken),
      body: jsonEncode({'customer_id': customerId, 'fcm_token': token}),
    );

    if (response.statusCode == 200) {
      log('Token updated on the server successfully.');
    } else {
      log('Failed to update token on the server. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      home: widget.onboarding
          ? const homeContainer(initialPage: 0)
          : OnboardingView(),
    );
  }
}
