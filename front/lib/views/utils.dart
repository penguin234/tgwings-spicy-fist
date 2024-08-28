import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

Future<Map<String, dynamic>> getStatus(Map<String, dynamic> user) async {
  final res = await http.post(
      Uri.parse('http://localhost:8080/user/status'), //uri는 나중에 통신할 때 입력
      headers: <String, String>{
        'Content-Type': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'id': user['id'],
        'session': user['cookie'][0],
      }));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

void updateStatus(Map<String, dynamic> user) async {
  final status = await getStatus(user);
  print('status $status');
  user['status'] = status['data']['data'];
}