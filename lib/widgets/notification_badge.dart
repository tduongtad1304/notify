import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;
  final double? width;
  final double? height;
  final double? countBadgeFontSize;
  final Color? color;
  const NotificationBadge({
    Key? key,
    required this.totalNotifications,
    this.width,
    this.height,
    this.countBadgeFontSize,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2.0),
          BoxShadow(
              color: Colors.white, offset: Offset(1, -1), blurRadius: 5.0),
        ],
      ),
      child: Center(
        child: Text(
          '$totalNotifications',
          style: TextStyle(color: Colors.white, fontSize: countBadgeFontSize),
        ),
      ),
    );
  }
}
