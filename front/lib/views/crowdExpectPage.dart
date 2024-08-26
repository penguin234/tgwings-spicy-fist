import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'readingRoom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getRooms() async {
  final res = await http.get(Uri.parse('https://libseat.khu.ac.kr/libraries/lib-status/2'));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return data['data'] as List<dynamic>;
}

class CrowdExpectPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const CrowdExpectPage(this.data, {super.key});

  @override
  _CrowdExpectPageState createState() {
    return _CrowdExpectPageState();
  }
}

class _CrowdExpectPageState extends State<CrowdExpectPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String formatTime(String start, String end) {
    if (end == "0000") end = "2400";
    return "${start.substring(0, 2)}:${start.substring(2, 4)}-${end.substring(0, 2)}:${end.substring(2, 4)}";
  }

  String formatDateTime(DateTime date, TimeOfDay time) {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return "$formattedDate $formattedTime";
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
          '예상 혼잡도',
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
                      widget.data['name'],
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.data['id'],
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Divider(
                color: Colors.black,
                thickness: 2.0,
                height: 2.0,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                color: Colors.white,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: khblue,
                      surfaceTintColor: khblue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026), // 마지막 날짜를 언제까지로 할지 상의 필요
                      );

                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedTime != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                            _selectedTime = selectedTime;
                          });
                        }
                      }
                    },
                    child: Text(
                      _selectedDate == null || _selectedTime == null
                          ? "날짜 및 시간 선택"
                          : formatDateTime(_selectedDate!, _selectedTime!),
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
             /* FutureBuilder<List<dynamic>>(future: getRooms(), builder: (context, snapshot) {
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
              }), 이 부분 이상함 */
            ],
          )
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
