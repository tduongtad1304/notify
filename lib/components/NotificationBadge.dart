// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;
  double? width;
  double? height;
  double? fontSize;
  Color? color;

  NotificationBadge(
      {Key? key,
      required this.totalNotifications,
      double? width,
      double? height,
      double? fontSize,
      Color? color})
      : super(key: key) {
    this.width = width;
    this.height = height;
    this.fontSize = fontSize;
    this.color = color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // ignore: unnecessary_new
      decoration: new BoxDecoration(
        color: color,
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
          child: Center(
            child: Text(
              '$totalNotifications',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }
}
