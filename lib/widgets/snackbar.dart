import 'package:flutter/material.dart';

///Floating [SnackBar] displaying with custom [snackBarContent].
SnackBar snackBar({required String snackBarContent}) {
  return SnackBar(
    padding: const EdgeInsets.all(5),
    width: 300,
    behavior: SnackBarBehavior.floating,
    content: Text(
      snackBarContent,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    duration: const Duration(seconds: 1),
  );
}
