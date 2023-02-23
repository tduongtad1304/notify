import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

OverlaySupportEntry showSimpleNotificationPopup(
    {void Function()? onTap,
    Widget? content,
    int? totalNotifications,
    Widget? subtitle}) {
  return showOverlayNotification(
    (context) => GestureDetector(
      onHorizontalDragEnd: (_) => OverlaySupportEntry.of(context)?.dismiss(),
      onTap: () {
        onTap?.call();
        OverlaySupportEntry.of(context)?.dismiss();
      },
      child: Card(
        color: Colors.white.withOpacity(0.75),
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(20),
        child: ListTile(
          style: ListTileStyle.drawer,
          leading: Icon(Icons.notifications),
          title: content,
          subtitle: subtitle,
        ),
      ),
    ),
    duration: Duration(milliseconds: 2000),
  );
}
