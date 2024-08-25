import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgthon/views/mainpage.dart';
import 'package:tgthon/views/qrPage.dart';
import 'package:tgthon/views/seatReservePage.dart';
import 'dart:math';
import 'data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import './utils.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  _MyLoginPageState createState() {
    return _MyLoginPageState();
  }
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<http.Response> login(String id, String pw) {
    return http.post(Uri.parse('http://localhost:8080/user/login'), // uri는 나중에 통신할 때 입력
        headers: <String, String>{
          'Content-Type': 'application/json'
        },
        body: jsonEncode(<String, String>{'id': id, 'pw': pw}));
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'BookSeat',
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'team SpicyFist',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                Image(
                  image: AssetImage('assets/team_logo.png'),
                  height: 40,
                ),
              ],
            ),
          ),
        ],
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
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/KHU.png'),
                width: 230,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'ID',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: khblue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      controller: _idController,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'PW',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: khblue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      obscureText: true,
                      controller: _pwController,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                        surfaceTintColor: khblue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          final res = await login(_idController.text, _pwController.text);
                          final studentData = jsonDecode(res.body) as Map<String, dynamic>;
                          if (studentData['ok'] == false) {
                            throw Exception(studentData['err']);
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MainPage(studentData),
                            ),
                          ); // 디버깅용으로 바꿔놓았는지 확인
                        } catch (e) {
                          showSnackbar(context, '로그인 실패');
                        }
                      },
                      child: Text('Sign in'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Image(
                image: AssetImage('assets/KHU.png'),
                width: 230,
                color: Colors.transparent,
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 5.0,
            right: 5.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final quote = goldenQuotes[Random().nextInt(goldenQuotes.length)];
                return AutoSizeText(
                  quote,
                  style: TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                  maxFontSize: 14,
                  minFontSize: 11,
                  stepGranularity: 1,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflowReplacement: AutoSizeText(
                    quote,
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                    maxFontSize: 14,
                    minFontSize: 11,
                    stepGranularity: 1,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
