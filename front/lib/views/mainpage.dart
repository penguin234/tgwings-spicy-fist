import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import './utils.dart';


class MainPage extends StatefulWidget{
  final Map<String, dynamic> data;
  const MainPage(this.data, {super.key});

  @override
  _MainPageState createState(){
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {

  @override
  void dispose(){
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
                        labelText: widget.data['name'],
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: khblue,
                              width: 2.0,
                            )
                        )
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                        labelText: widget.data['id'],
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: khblue,
                              width: 2.0,
                            )
                        )
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                        surfaceTintColor: khblue,
                        foregroundColor: Colors.white
                    ),
                    onPressed: () async{
                      try {

                      }
                      catch (e) {
                        showSnackbar(context, '로그인 실패');
                      }
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