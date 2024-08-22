import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'readingRoom.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> readingRooms = [
      {"name": "1F 제1열람실", "time": "00:00~24:00"},
      {"name": "1F 벗터", "time": "06:00~24:00"},
      {"name": "2F 혜윰", "time": "09:00~17:30"},
      {"name": "2F 제2열람실", "time": "00:00~24:00"},
      {"name": "전정대 1F 열람실", "time": "00:00~24:00"},
    ];

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
          Column(
            children: [
              SizedBox(height: 50),
              ...readingRooms.map((room) {
                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReadingRoom(widget.data),
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
                                          room["time"]!,
                                          style: GoogleFonts.notoSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "이용 가능 좌석수 / 전체 좌석수",
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
                              Container(
                                width: 100,
                                height: 10,
                                child: LinearProgressIndicator(
                                  value: 0.5, // 이용율은 나중에 API로 받아서 처리
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(khblue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}
