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
