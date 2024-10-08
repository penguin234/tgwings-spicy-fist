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

Future<void> updateStatus(Map<String, dynamic> user) async {
  final status = await getStatus(user);
  print('status $status');
  if (status['ismy'] != null) {
    user['status'] = {
      'ismy': true,
      'data': status['data'],
      'addCount': 0,
    };
    return;
  }
  user['status'] = status['data']['data'];
  user['status']['addCount'] = 0;
}

String fromMillis(millis) {
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${dt.year.toString()}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

Future<List<dynamic>> getSeats(int roomCode) async {
  if (roomCode == 12) {
    final res = await http.get(Uri.parse('http://localhost:8080/room/seats'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  final res = await http.get(Uri.parse('https://libseat.khu.ac.kr/libraries/seats/$roomCode'));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return data['data'] as List<dynamic>;
}