import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'readingRoom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getRooms() async {
  final res = await http.get(Uri.parse('https://libseat.khu.ac.kr/libraries/lib-status/2'));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  List<dynamic> ls = data['data'] as List<dynamic>;
  ls.add({
    'code': 12,
    'name': '자대 열람실',
    'inUse': 0,
    'cnt': 47,
    'startTm': '0000',
    'endTm': '0000'
  });
  return ls;
}

class SeatReservePage extends StatefulWidget {
  final Map<String, dynamic> data;
  const SeatReservePage(this.data, {super.key});

  @override
  _SeatReservePageState createState() {
    return _SeatReservePageState();
  }
}

class _SeatReservePageState extends State<SeatReservePage> {
  @override
  void dispose() {
    super.dispose();
  }

  String formatTime(String start, String end) {
    if (end == "0000") end = "2400";
    return "${start.substring(0, 2)}:${start.substring(2, 4)}-${end.substring(0, 2)}:${end.substring(2, 4)}";
  }

  @override
  Widget build(BuildContext context) {
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
          '좌석 예약',
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
          FutureBuilder<List<dynamic>>(future: getRooms(), builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  SizedBox(height: 50),
                  ...snapshot.data!.map(fromRoom).toList(),
                  SizedBox(height: 50),
                ],
              );
            }
            return Text("Loading...");
          }),
        ],
      ),
    );
  }

  Widget fromRoom(dynamic roomData) {
    final room = roomData as Map<String, dynamic>;
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReadingRoom(widget.data, room),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              room["name"]!,
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              formatTime(room["startTm"], room["endTm"]),
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          (room["cnt"] - room["inUse"]).toString() + " / " + room["cnt"].toString() + " 이용 가능",
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "이걸 찾아?",
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.transparent
                        ),
                      ),
                      Container(
                      width: 100,
                      height: 10,
                      child: LinearProgressIndicator(
                        value: room["inUse"] / room["cnt"],
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(khblue),
                      ),
                    ),
                      SizedBox(height: 8),
                      Text(
                        room["inUse"].toString() + " 이용 중",
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
