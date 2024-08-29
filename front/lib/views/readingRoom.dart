import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgthon/views/QRpage.dart';
import 'package:tgthon/views/crowdExpectPage.dart';
import 'package:tgthon/views/myPage.dart';
import 'package:tgthon/views/seatReservePage.dart';
import './utils.dart';
import '../theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getSeats(int roomCode) async {
  if (roomCode == 12) {
    final res = await http.get(Uri.parse('http://localhost:8080/room/seats'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  final res = await http.get(Uri.parse('https://libseat.khu.ac.kr/libraries/seats/$roomCode'));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return data['data'] as List<dynamic>;
}

class ReadingRoom extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> room;
  const ReadingRoom(this.data, this.room, {super.key});

  @override
  _ReadingRoomState createState() {
    return _ReadingRoomState();
  }
}

class _ReadingRoomState extends State<ReadingRoom> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransformationController controller = TransformationController();
    controller.value = Matrix4.identity()..scale(2.5);

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
          widget.room['name'],
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.symmetric(vertical: 100, horizontal: 0),
          transformationController: controller,
          minScale: 0.05,
          maxScale: 5.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AspectRatio(aspectRatio: 1380 / 700,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: 
                      AssetImage("rooms/${widget.room['code']}.${widget.room['code']==12?'png':'jpg'}"),
                    ),
                  ),
                  child:
                    LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      Size containerSize = Size(
                        constraints.maxWidth, constraints.maxWidth * 700 / 1380
                      );
                      return FutureBuilder<List<dynamic>>(future: getSeats(widget.room['code']), builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                            children: snapshot.data!.map((seat) => makeSeat(seat, context, containerSize)).toList(),
                          );
                        }
                        return Text('');
                      });
                    }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeSeat(seatData, context, containerSize) {
    Map<String, dynamic> seat = seatData as Map<String, dynamic>;
    final bool isActive = seat['seatTime'] == null;
    double xpos = ((seat['xpos'] / 1920) * containerSize.width);
    double ypos = ((seat['ypos'] / 900) * containerSize.height);
    double width = (seat['width'] / 1920) * containerSize.width;
    double height = (seat['height'] / 900) * containerSize.height;
    final Color boxColor = khblue; // 사용 가능 좌석 색
    final Color textColor = Colors.white; // 사용 가능 좌석 텍스트 색
    const Color inactiveColor = Colors.grey; // 사용중 좌석 색
    const Color inactiveTextColor = Colors.white; // 사용중 좌석 텍스트 색
    final Color mySeatColor =Colors.orange;
    final Color selectedTextColor = Colors.black;

    bool isMySeat = false;
    if (widget.data['status']['mySeat'] != null) {
      if (widget.data['status']['mySeat']['seat']['code'] == seat['code']) {
        isMySeat = true;
      }
    }

    // for some correcting positions
    if (widget.room['code'] == 11) {
      // 혜움
      final int seatNo = int.parse(seat['name']);
      if (seatNo >= 9 && seatNo <= 27) {
        ypos -= 2;
      }
    }

    if (widget.room['code'] == 10) {
      // 벗터
      //xpos *= 0.8;
      ypos *= 0.72;
      //xpos += 100;
      ypos += 30;
      //width *= 0.8;
      height *= 0.72;
    }

    if (widget.room['code'] == 12) {
      // 자대 열람실
      xpos *= 0.9;
      width *= 0.9;
      ypos *= 0.85;
      height *= 0.85;
    }

    return Positioned(
      left: xpos,
      top: ypos,
      child: GestureDetector(
        onTap: () {
          if (isMySeat) return;
          if (isActive) {
            reserveDialog(context, widget.data, seat, widget.room);
          }
          else {
            alarmDialog(context, widget.data, seat, widget.room['name']);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: !isMySeat ? isActive ? boxColor : inactiveColor : mySeatColor,
          ),
          width: width - 0.5,
          height: height - 0.5,
          child: Center(
            child: Text(
              seat['name'],
              style: TextStyle(
                color: isActive ? textColor : inactiveTextColor,
                fontSize: widget.room['code'] == 12 ? 4 : width / 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void reserveDialog(BuildContext context, Map<String, dynamic> userData, Map<String, dynamic> seat, Map<String, dynamic> room) {
  int selectedHour = 1; // Default value
  int selectedMinute = 0; // Default value
  List<int> ableMinute = [0, 30];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 좌측: 사용 시간 선택
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "사용 시간 선택",
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 시간 선택 드롭다운
                                DropdownButton<int>(
                                  value: selectedHour,
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedHour = newValue!;
                                      if (selectedHour == 4) {
                                        ableMinute = [0];
                                        selectedMinute = 0;
                                      }
                                      else {
                                        ableMinute = [0, 30];
                                      }
                                    });
                                  },
                                  items: [1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(width: 4),
                                Text("시간", style: GoogleFonts.notoSans()),
                                SizedBox(width: 16),
                                // 분 선택 드롭다운
                                DropdownButton<int>(
                                  value: selectedMinute,
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedMinute = newValue!;
                                    });
                                  },
                                  items: ableMinute.map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString().padLeft(2, '0')),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(width: 4),
                                Text("분", style: GoogleFonts.notoSans()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32),
                      // 우측: 정보 박스
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            InfoBox(title: "입실확인", content: "${formatHHMM(DateTime.now().hour, DateTime.now().minute, 30)}까지"),
                            SizedBox(height: 8),
                            InfoBox(title: "배정시간", content: "${formatHHMM(DateTime.now().hour, DateTime.now().minute, selectedHour * 60 + selectedMinute)}까지"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // 하단 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: khblue,
                          ),
                          onPressed: () async {
                            final res;
                            /*if(room['code'] == 12){
                                  res = await http.post(
                                  Uri.parse('http://localhost:8080/user/reserve'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json'
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    'id': userData['id'],
                                    'session': userData['cookie'][0],
                                    'seatNumber': seat['code'],
                                    'time': selectedHour * 60 + selectedMinute
                                  })
                              );
                            } */
                            //else{
                                  res = await http.post(
                                  Uri.parse('http://localhost:8080/user/seat/use'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json'
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    'id': userData['id'],
                                    'session': userData['cookie'][0],
                                    'code': seat['code'],
                                    'time': selectedHour * 60 + selectedMinute
                                  })
                              );
                            //}
                            print(res.body);
                            final data = jsonDecode(res.body) as Map<String, dynamic>;
                            if (!data['ok']) {
                              showSnackbar(context, data['err']);
                              Navigator.of(context).pop();
                              return;
                            }


                            await updateStatus(userData);

                            setState(() {});

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "좌석 배정",
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "취소",
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


class InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const InfoBox({
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

void alarmDialog(BuildContext context, Map<String, dynamic> userData, Map<String, dynamic> seat, Map<String, dynamic> room) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline, // 확성기 모양의 아이콘
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "이미 사용 중인 좌석입니다. 사용 종료 알람을 받으시겠습니까?",
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khblue,
                      ),
                      onPressed: () async {
                        final res = await http.post(
                            Uri.parse('http://localhost:8080/seats/reserve/reserve'),
                            headers: <String, String>{
                              'Content-Type': 'application/json'
                            },
                            body: jsonEncode(<String, dynamic>{
                              'id': userData['id'],
                              'session': userData['cookie'][0],
                              'seatNumber': seat['code'],
                              'seatName': seat['name'],
                              'seatGroup': room,
                            })
                        );

                        final data = jsonDecode(res.body) as Map<String, dynamic>;
                        if (!data['ok']) {
                          showSnackbar(context, data['err']);
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "예",
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "아니오",
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
