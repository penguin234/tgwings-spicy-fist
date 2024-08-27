import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<Map<String, dynamic>> getQR(Map<String, dynamic> data) async {
  final res = await http.post(Uri.parse('http://localhost:8080/user/qr'), //uri는 나중에 통신할 때 입력
      headers: <String, String>{
        'Content-Type': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'id': data['id'],
        'session': data['cookie'][0],
      }));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

class QRpage extends StatefulWidget {
  final Map<String, dynamic> data;
  const QRpage(this.data, {super.key});

  @override
  _QRpageState createState() {
    return _QRpageState();
  }
}

class _QRpageState extends State<QRpage> {
  late int _deadline;

  String _formatTime(int millis) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(millis);
    String hourStr = time.hour.toString().padLeft(2, '0');
    String minStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minStr';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deadline = DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          '이용증',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
        body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: khred,
                  image: DecorationImage(
                    image: AssetImage('assets/lion.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: getQR(widget.data),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!snapshot.data!['ok']) {
                      return Text('오류 ${snapshot.data!['err']}');
                    }
                    return ofQR(snapshot.data!['QR']);
                  }
                  return Text('로딩중');
                }
              )
            ]
        )
    );
  }

  Widget ofQR(String qrString) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QrImageView(
          data: qrString,
          backgroundColor: Colors.white,
          version: 7,
          size: 200,
        ),
        SizedBox(height: 20),
        Text(
          "이 QR코드는${_formatTime(_deadline)}까지 유효합니다.",
          style: GoogleFonts.notoSans(
            fontSize: 17,
            color: Colors.white60,
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20.0,
                  offset: Offset(0,2),
                )
              ]
          ),
          width: 180,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: khblue,
                surfaceTintColor: khblue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
            ),
            onPressed: (){ setState((){}); },
            child: Text('새로고침'),
          ),
        ),
      ],
    );
  }
}
