// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notification',
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;
}

class _HomePageState extends State {
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;

  void registerNotification() async {
    print('BEGIN');
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    String? token = await FirebaseMessaging.instance.getToken();
    print(token);

    // FirebaseMessaging.instance.getToken().then((token) {
    //   print('FCM TOKEN:');
    //   print(token);
    //   print('END');
    // });

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(
          color: Colors.black45,
          fontWeight: FontWeight.w600,
          fontSize: 19,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Thông Báo',
        ),
        elevation: 0,
        leading: Icon(
          Icons.notifications,
          color: Colors.black45,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Text(
              'Nhận thông báo đẩy gửi về từ Firebase Cloud Messaging',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withAlpha(180),
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
