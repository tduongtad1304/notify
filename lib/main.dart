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
  List listNotification = [];

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
          listNotification.add(_notificationInfo);
        });

        // For displaying the notification as an overlay
        if (_notificationInfo != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!,
                style: TextStyle(color: Colors.black87)),
            autoDismiss: true,
            slideDismissDirection: DismissDirection.horizontal,
            leading: NotificationBadge(
              totalNotifications: _totalNotifications,
              width: 40.0,
              height: 40.0,
              fontSize: 20.0,
              color: Colors.lightBlue.shade300,
            ),
            trailing:
                Icon(Icons.navigate_next, size: 50, color: Colors.black54),
            elevation: 10,
            subtitle: Text(_notificationInfo!.body!,
                style: TextStyle(color: Colors.black87)),
            background: Colors.lightBlue.shade50.withOpacity(0.7),
            foreground: Colors.teal.shade100.withOpacity(0.7),
            duration: Duration(seconds: 5),
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
        listNotification.add(_notificationInfo);
      });
    }
  }

  //Handling notifications on the screen, set to delete all notifications.
  deleteAllNotification() {
    setState(() {
      _notificationInfo = null;
      _totalNotifications = 0;
      listNotification.removeRange(0, listNotification.length);
    });
    print('Deleted all notifications');
    if (_totalNotifications == 0) {
      print('No notifications for deleting');
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    listNotification = [];
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
        listNotification.add(_notificationInfo);
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
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.black45,
                size: 40,
              ),
              Positioned(
                left: 15,
                child: NotificationBadge(
                  totalNotifications: _totalNotifications,
                  width: 23,
                  height: 23,
                  fontSize: 8,
                  color: Colors.amber.shade800,
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          NotificationBadge(
            totalNotifications: _totalNotifications,
            width: 40.0,
            height: 40.0,
            fontSize: 20.0,
            color: Colors.lightBlue.shade300,
          ),
          SizedBox(height: 16.0),
          _notificationInfo != null
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _totalNotifications,
                    itemBuilder: (context, index) => Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          setState(() {
                            listNotification.removeAt(index);
                            _totalNotifications--;
                            if (_totalNotifications == 0) {
                              _notificationInfo = null;
                            }
                          });
                          print('The notification has been deleted');
                        }
                        if (direction == DismissDirection.startToEnd) {
                          print('The notification has been archived');
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10.0),
                        color: Colors.blue,
                        child: Icon(Icons.archive, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(left: 10.0),
                        color: Colors.redAccent,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: 300,
                            decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54,
                                      offset: Offset(2, 2),
                                      blurRadius: 2.5,
                                      blurStyle: BlurStyle.normal),
                                ]),
                            child: Column(
                              children: [
                                Text(
                                  '${listNotification[index]!.title ?? {
                                        listNotification[index]!.dataTitle
                                      }}',
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${listNotification[index]!.body ?? {
                                        listNotification[index]!.dataBody
                                      }}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Text('No notifications'),
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
