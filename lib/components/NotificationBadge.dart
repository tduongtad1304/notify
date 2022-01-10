import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({Key? key, required this.totalNotifications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      // ignore: unnecessary_new
      decoration: new BoxDecoration(
        color: Colors.lightBlue.shade300,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2.0),
          BoxShadow(
              color: Colors.white, offset: Offset(1, -1), blurRadius: 5.0),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
