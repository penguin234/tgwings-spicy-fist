import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const khred = Color.fromARGB(255, 164, 15, 22);
const khblue = Color.fromARGB(255, 13, 50, 111);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyLoginPage()
    );
  }
}

class MyLoginPage extends StatefulWidget{
  @override
  _MyLoginPageState createState(){
    return _MyLoginPageState();
  }
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<http.Response> login(String id, String pw){
    return http.post(Uri.parse('http://ip주소:포트주소/user/login'), //uri는 나중에 통신할 때 입력
        headers: <String, String>{
          'Content-Type': 'application/json'
        },
        body: jsonEncode(<String, String>{
          'id': id,
          'pw': pw
        }));
  }

  @override
  void dispose(){
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
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
          Positioned(
              top: 230,
              child: Image(
                image: AssetImage('assets/KHU.png'),
                width: 230,
              )
          ),
          Center(
            child: Container(
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
                            )
                        )
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
                            )
                        )
                    ),
                    obscureText: true,
                    controller: _pwController,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                        surfaceTintColor: khblue,
                        foregroundColor: Colors.white
                    ),
                    onPressed: () async{
                      print(_idController.text + '\n' + _pwController.text); //id 및 pw 입력 텍스트를 올바르게 인식하는지 확인용
                      final res = await login(_idController.text, _pwController.text); //login 함수 호출, 백엔드에 입력받은 id와 pw 전송
                      print(jsonDecode(res.body) as Map<String, dynamic>); //백엔드 response 출력(로그인 성공시 이름 및 학번)
                    },
                    child: Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 5.0,
            right: 5.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
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
