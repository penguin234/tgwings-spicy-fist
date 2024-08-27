import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'readingRoom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const MyPage(this.data, {super.key});

  @override
  _MyPageState createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  List<Map<String, dynamic>> seats = [
    {'room': '자대 열람실', 'name': 30, 'code': 1234},
    {'room': '1 열람실', 'name': 102, 'code': 1235},
    {'room': '벗터', 'name': 67, 'code': 1236},
    {'room': '2 열람실', 'name': 123, 'code': 1237},
    {'room': '1 열람실', 'name': 245, 'code': 1238},
    {'room': '벗터', 'name': 167, 'code': 1239},
    {'room': '2 열람실', 'name': 35, 'code': 1240},
    {'room': '2 열람실', 'name': 22, 'code': 1241},
    {'room': '1 열람실', 'name': 11, 'code': 1242},
  ];

  List<bool> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    selectedSeats = List<bool>.filled(seats.length, false);
  }

  void deleteSelectedSeats() {
    setState(() {
      seats = seats
          .asMap()
          .entries
          .where((entry) => !selectedSeats[entry.key])
          .map((entry) => entry.value)
          .toList();
      selectedSeats = List<bool>.filled(seats.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: khblue,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          '내 정보',
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: khblue,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Divider(
            color: khblue,
            thickness: 2.0,
            height: 2.0,
          ),
          Container(
            width: double.infinity,
            color: Colors.grey,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "좌석 배정내역 상세정보",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            color: khblue,
            thickness: 2.0,
            height: 2.0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "사용자명: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: widget.data['name'],
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "좌석정보: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "국제캠퍼스/열람실 이름/좌석번호",
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "배정시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "YYYY.MM.DD HH:MM",
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "종료시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "YYYY.MM.DD HH:MM",
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "연장시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "HH:MM~",
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "입실처리상태: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: khred,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "확인 or 미확인",
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text("퇴실"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text("연장"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: khblue,
            thickness: 2.0,
            height: 2.0,
          ),
          Container(
            width: double.infinity,
            color: Colors.grey,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "퇴실 알림 정보",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            color: khblue,
            thickness: 2.0,
            height: 2.0,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 2.5,
                ),
                itemCount: seats.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: khblue),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "${seats[index]['room']}/${seats[index]['name']}",
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Checkbox(
                            value: selectedSeats[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedSeats[index] = value!;
                              });
                            },
                            activeColor: khred,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: deleteSelectedSeats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khred,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text("선택 삭제"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
