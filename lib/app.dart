import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'pages/home_page.dart';

Future firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId} with title: ${message.notification?.title}, body: ${message.notification?.body} and image url: ${message.notification?.android?.imageUrl}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notification',
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
