import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {int duration = 2}) {
  final snackBar = SnackBar(
    content: Text(
        message,
        textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: duration),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String formatHHMM(int hour, int minute, [int delta = 0]) {
  minute += delta;
  hour += minute ~/ 60;
  minute %= 60;
  hour %= 24;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}