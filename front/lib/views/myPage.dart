import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'readingRoom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './utils.dart';

Future<List<dynamic>> getWatchSeats(Map<String, dynamic> userData) async {
  final ls = await http.post(
    Uri.parse('http://localhost:8080/seats/reserve/reserve/my'),
    headers: <String, String>{
      'Content-Type': 'application/json'
    },
    body: jsonEncode(<String, dynamic>{
      'id': userData['id'],
      'session': userData['cookie'][0],
    }),
  );

  final res = jsonDecode(ls.body) as Map<String, dynamic>;
  if (!res['ok']) {
    return [];
  }

  return res['data'];
}

class MyPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const MyPage(this.data, {super.key});

  @override
  _MyPageState createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  List<dynamic> ls = [];

  List<bool> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    selectedSeats = List<bool>.filled(ls.length, false);
  }

  void deleteSelectedSeats() {
    setState(() {
      ls = ls
          .asMap()
          .entries
          .where((entry) => !selectedSeats[entry.key])
          .map((entry) => entry.value)
          .toList();
      selectedSeats = List<bool>.filled(ls.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        title: Text(
          '내 정보',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'LOGOUT',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: khred,
          image: DecorationImage(
            image: AssetImage('assets/lion.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.data['name']}',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.data['id']}',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 좌석 배정 내역 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.data['status']['mySeat'] != null ? [
                    Text(
                      "좌석 배정 내역",
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "좌석 정보: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "국제캠퍼스 ${widget.data['status']['mySeat']['seat']['group']['name']} ${widget.data['status']['mySeat']['seat']['name']}",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "입실 시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "${fromMillis(widget.data['status']['mySeat']['confirmTime'])}",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "퇴실 시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "${fromMillis(widget.data['status']['mySeat']['expireTime'])}",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "좌석 연장: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "${widget.data['status']['addCount']}회 연장(${3 - widget.data['status']['addCount']}회 가능)",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "입실 처리: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: widget.data['status']['mySeat']['state'] == 5 ? "승인" : "미승인",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: khblue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await http.post(
                                Uri.parse('http://localhost:8080/user/seat/exit'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json'
                                },
                                body: jsonEncode(<String, dynamic>{
                                  'id': widget.data['id'],
                                  'session': widget.data['cookie'][0],
                                  'code': widget.data['status']['mySeat']['seat']['code'],
                                })
                            );

                            await updateStatus(widget.data);

                            print("퇴실");

                            setState(() {

                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: khred,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("퇴실"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (widget.data['status']['addCount'] >= 3) {
                              showSnackbar(context, '연장 횟수 초과');
                              return;
                            }

                            /*
                            final res = await http.post(
                              Uri.parse('http://localhost:8080/user/seat/extend'),
                              headers: <String, String>{
                                'Content-Type': 'application/json'
                              },
                              body: jsonEncode(<String, dynamic>{
                                'id': widget.data['id'],
                                'session': widget.data['cookie'][0],
                                'code': widget.data['status']['mySeat']['seat']['code'],
                                'group': widget.data['status']['mySeat']['seat']['group']['code']
                              }),
                            );

                            print(jsonDecode(res.body));
                            */
                            widget.data['status']['mySeat']['expireTime'] +=
                              (widget.data['status']['mySeat']['expireTime'] - widget.data['status']['mySeat']['confirmTime']) ~/ (widget.data['status']['addCount'] + 1);

                            widget.data['status']['addCount']++;
                            setState((){});
                          },
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
                  ] : (widget.data['status']['ismy'] != null ? [
                    Text(
                      "좌석 배정 내역",
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "좌석 정보: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "국제캠퍼스 자대 열람실 ${widget.data['status']['data']['seatNumber']}",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "입실 시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: fromMillis(widget.data['status']['data']['reservedTime']),
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "퇴실 시간: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: fromMillis(widget.data['status']['data']['reservedTime'] + widget.data['status']['data']['time'] * 60 * 1000),
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "좌석 연장: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "${widget.data['status']['addCount']}회 연장(${3 - widget.data['status']['addCount']}회 가능)",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "입실 처리: ",
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "승인",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                              color: khblue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await http.post(
                                Uri.parse('http://localhost:8080/user/seat/exit'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json'
                                },
                                body: jsonEncode(<String, dynamic>{
                                  'id': widget.data['id'],
                                  'session': widget.data['cookie'][0],
                                  'code': widget.data['status']['data']['seatNumber'],
                                })
                            );

                            await updateStatus(widget.data);

                            setState(() {

                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: khred,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("퇴실"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.data['status']['addCount']++;
                            setState((){});
                          },
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
                  ] : [
                    Text(
                      "좌석 배정 내역",
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "배정 좌석 없음",
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ])
                ),
              ),
            ),
            // 퇴실 알림 섹션
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: FutureBuilder(future: getWatchSeats(widget.data), builder: (context, snapshot) {
                      var ls = [];
                      if (snapshot.hasData) {
                        ls = snapshot.data!;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "퇴실 알림",
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: ls.length,
                              separatorBuilder: (context, index) =>
                                  Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${ls[index]['group']} ${ls[index]['name']}",
                                          style: GoogleFonts.notoSans(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: khred),
                                        onPressed: () async {
                                          await http.post(
                                            Uri.parse('http://localhost:8080/seats/reserve/reserve/off'),
                                            headers: <String, String>{
                                              'Content-Type': 'application/json'
                                            },
                                            body: jsonEncode(<String, dynamic>{
                                              'id': widget.data['id'],
                                              'session': widget.data['cookie'][0],
                                              'seatNumber': ls[index]['code'],
                                            }),
                                          );

                                          setState(() {

                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
