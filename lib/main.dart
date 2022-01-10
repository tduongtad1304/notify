// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'components/NotificationBadge.dart';
import 'components/PushNotification.dart';

void main() {
  runApp(const MyApp());
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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

class _HomePageState extends State {
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

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
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // ignore: todo
      // TODO: handle the received notifications
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        // For displaying the notification as an overlay
        if (_notificationInfo != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!,
                style: TextStyle(color: Colors.black87)),
            autoDismiss: true,
            slideDismissDirection: DismissDirection.horizontal,
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            trailing:
                Icon(Icons.navigate_next, size: 50, color: Colors.black54),
            elevation: 10,
            subtitle: Text(_notificationInfo!.body!,
                style: TextStyle(color: Colors.black87)),
            background: Colors.lightBlue.shade50.withOpacity(0.7),
            foreground: Colors.teal.shade100.withOpacity(0.7),
            duration: Duration(seconds: 10),
            contentPadding: EdgeInsets.all(10),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  //Handling notifications on the screen, set to delete all notifications.
  deleteAllNotification() {
    setState(() {
      _notificationInfo = null;
      _totalNotifications = 0;
    });
    if (_totalNotifications == 0) {
      print('No notifications for deleting');
    } else {
      print('Deleted all notifications');
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();
    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

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
          NotificationBadge(totalNotifications: _totalNotifications),
          SizedBox(height: 16.0),
          _notificationInfo != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiêu đề: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      const SizedBox(height: 8.0),
                      Text(
                        'Nội dung: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red)),
                onPressed: () => setState(() {
                      deleteAllNotification();
                    }),
                child: Text('Delete All')),
          ),
        ],
      ),
    );
  }
}
