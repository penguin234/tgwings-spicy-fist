import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getRooms(_date, _time) async {
  if (_date == null || _time == null) return [];

  DateTime date = _date!;
  TimeOfDay time = _time!;

  final pdate = "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
  final ptime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  final res = await http.get(Uri.parse('https://libseat.khu.ac.kr/libraries/lib-status/2'));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  var ls = data['data'] as List<dynamic>;

  ls.add({
    'code': 12,
    'name': '자대 열람실',
    'inUse': 0,
    'cnt': 47,
    'startTm': '0000',
    'endTm': '0000'
  });

  for (int i = 0; i < ls.length; i++) {
    final pd = await http.get(Uri.parse("http://localhost:8000/predict/${ls[i]['code']}/$pdate/$ptime"));
    ls[i]['predict'] = (jsonDecode(pd.body) as Map<String, dynamic>)['predict'];
  }

  return ls;
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        lastDate: DateTime(DateTime.now().year + 1, DateTime.now().month, 1),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: khblue,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: khblue,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: child!,
                            );
                          },
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
              Spacer(flex: 1),
              FutureBuilder<List<dynamic>>(future: getRooms(_selectedDate, _selectedTime), builder: (context, snapshot) {
                if (_selectedDate == null || _selectedTime == null) {
                  return Text(
                      '날짜 및 시간을 선택하세요.',
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white60,
                      ),
                  );
                }

                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.map<Widget>((roomData) {
                      return fromRoom(roomData);
                    }).toList(),
                  );
                }

                return Text(
                    "Loading...",
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white60,
                    ),
                );
              }),
              Spacer(flex: 1),
            ],
          )
        ],
      ),
    );
  }

  Widget fromRoom(dynamic roomData) {
    final room = roomData as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
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
                      room["predict"].toString() + " / " + room["cnt"].toString() + " 이용 예상",
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
                      value: room["predict"] / room["cnt"],
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(khblue),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    room["predict"] / room["cnt"] < 2 / 3 ? room["predict"] / room["cnt"] < 1 / 3 ? "원활" : "보통" : "혼잡", //원활 0~33 보통 34~ 67 혼잡 68~100
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
    );
  }
}
