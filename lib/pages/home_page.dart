import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../app.dart';
import '../model/notification.dart';
import '../widgets/widgets.dart';
import 'notification_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  Notifications? _notificationInfo;
  late List<Notifications?> _listNotification;

  Future<void> registerNotification() async {
    log('BEGIN');
    // 1. Instantiate Firebase Messaging instance.
    _messaging = FirebaseMessaging.instance;
    // 2. Get firebase token
    String? token = await _messaging.getToken();
    log('Firebase Token: ${token.toString()}');

    // 3. Instantiate Firebase Messaging Background Handler.
    log('Registering background handler');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Request permission.
    log('Requesting permission');
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    /// Handling permission on Android specifically.
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Alert'),
          content: Text('Notification permission granted in system settings.'),
        ),
      );
      // Handle the received notifications when the app is in the foreground.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}, imgUrl: ${Platform.isAndroid ? message.notification?.android?.imageUrl : message.notification?.apple?.imageUrl}');
        Notifications notification = Notifications(
          title: message.notification?.title,
          body: message.notification?.body,
          imgUrl: Platform.isAndroid
              ? message.notification?.android?.imageUrl
              : message.notification?.apple?.imageUrl,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
          _listNotification.add(_notificationInfo);
        });

        //Displaying the notification as an overlay.
        if (_notificationInfo != null) {
          showSimpleNotificationPopup(
            onTap: () {
              Navigator.of(context).push(
                pageBuilderTransition(
                  NotificationDetailsPage(
                    title: _notificationInfo?.title,
                    subTitle: _notificationInfo?.body,
                    imgUrl: _notificationInfo?.imgUrl,
                  ),
                ),
              );
            },
            content: Text(
              _notificationInfo?.title ?? 'No title',
              style: TextStyle(color: Colors.black87),
            ),
            subtitle: Text(
              _notificationInfo?.body ?? 'No body',
              style: TextStyle(color: Colors.black87),
            ),
            totalNotifications: _totalNotifications,
          );
        }
      }, onError: (error) => log('Error: $error'));
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Alert'),
          content: Text('Notification permission denied in system settings.'),
        ),
      );
    }
  }

  /// Handling notification when the app is in terminated state.
  Future<void> checkForInitialMessage() async {
    log('Check for initial message');
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      Notifications notification = Notifications(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        imgUrl: Platform.isAndroid
            ? initialMessage.notification?.android?.imageUrl
            : initialMessage.notification?.apple?.imageUrl,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      if (notification.title != null && notification.body != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NotificationDetailsPage(
              title: notification.title,
              subTitle: notification.body,
              imgUrl: notification.imgUrl,
            ),
          ),
        );
      } else {
        return;
      }

      // setState(() {
      //   _notificationInfo = notification;
      //   _totalNotifications++;
      //   listNotification.add(_notificationInfo);
      // });
    }
  }

  void onMessageOpenedApp() {
    /// For handling notification when the app is in background but not terminated.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('On Message Opend App');
      Notifications notification = Notifications(
        title: message.notification?.title,
        body: message.notification?.body,
        imgUrl: Platform.isAndroid
            ? message.notification?.android?.imageUrl
            : message.notification?.apple?.imageUrl,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      Navigator.of(context).push(
        pageBuilderTransition(
          NotificationDetailsPage(
            title: notification.title,
            subTitle: notification.body,
            imgUrl: notification.imgUrl,
          ),
        ),
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
        _listNotification.add(_notificationInfo);
      });
    });
  }

  ///Handling notifications on the screen, set to delete all notifications.
  void deleteAllNotification() {
    setState(() {
      _notificationInfo = null;
      _totalNotifications = 0;
      _listNotification.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar(snackBarContent: 'All notifications deleted'),
    );
  }

  @override
  void initState() {
    _totalNotifications = 0;
    _listNotification = [];
    registerNotification().whenComplete(() => checkForInitialMessage());
    onMessageOpenedApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              'Receive messages from FCM',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withAlpha(180),
                fontSize: 20,
              ),
            ),
            SizedBox(height: 16.0),
            NotificationBadge(
              totalNotifications: _totalNotifications,
              width: 40.0,
              height: 40.0,
              countBadgeFontSize: 20.0,
              color: Colors.lightBlue.shade300,
            ),
            SizedBox(height: 20.0),
            _notificationInfo != null
                ? Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: _totalNotifications,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 20),
                      itemBuilder: (context, index) => Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          setState(() {
                            _listNotification.removeAt(index);
                            _totalNotifications--;
                            if (_totalNotifications == 0) {
                              _notificationInfo = null;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBar(
                                snackBarContent:
                                    'Notification deleted successfully'),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10.0),
                          color: Colors.redAccent,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(left: 10.0),
                          color: Colors.redAccent,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _listNotification.isNotEmpty
                            ? NotificationCell(
                                isHasImage:
                                    _listNotification[index]?.imgUrl != null &&
                                        _listNotification[index]?.imgUrl != '',
                                onTap: () {
                                  Navigator.of(context).push(
                                    pageBuilderTransition(
                                      NotificationDetailsPage(
                                        title: _listNotification[index]
                                                ?.title ??
                                            _listNotification[index]?.dataTitle,
                                        subTitle: _listNotification[index]
                                                ?.body ??
                                            _listNotification[index]?.dataBody,
                                        imgUrl:
                                            _listNotification[index]?.imgUrl,
                                      ),
                                    ),
                                  );
                                },
                                title: _listNotification[index]?.title ??
                                    _listNotification[index]?.dataTitle,
                                body: _listNotification[index]?.body ??
                                    _listNotification[index]?.dataBody,
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  )
                : Text('No notifications', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => setState(() => deleteAllNotification()),
                child: Text('Delete All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      titleTextStyle: TextStyle(
          color: Colors.black45, fontWeight: FontWeight.w600, fontSize: 19),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: const Text('Notification Demo'),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          children: [
            Icon(Icons.notifications, color: Colors.black45, size: 40),
            Positioned(
              left: 20,
              child: NotificationBadge(
                totalNotifications: _totalNotifications,
                width: 23,
                height: 23,
                countBadgeFontSize: 13,
                color: Colors.amber.shade800,
              ),
            )
          ],
        ),
      ),
    );
  }
}
