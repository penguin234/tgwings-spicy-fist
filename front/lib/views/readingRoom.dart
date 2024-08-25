import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgthon/views/QRpage.dart';
import 'package:tgthon/views/crowdExpectPage.dart';
import 'package:tgthon/views/myPage.dart';
import 'package:tgthon/views/seatReservePage.dart';
import '../theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getSeats(int roomCode) async {
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
                      AssetImage("rooms/${widget.room['code']}.jpg"),
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
                        return Text('로딩중');
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
    final Color selectedColor =Colors.white;
    final Color selectedTextColor = Colors.black;

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
      xpos *= 0.8;
      ypos *= 0.8;
      xpos += 100;
      ypos += 100;
      width *= 0.8;
      height *= 0.8;
    }

    return Positioned(
      left: xpos,
      top: ypos,
      child: GestureDetector(
        onTap: () {
          if (isActive) {
            reserveDialog(context, seat);
          }
          else {
            alarmDialog(context, seat);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? boxColor : inactiveColor,
          ),
          width: width - 0.5,
          height: height - 0.5,
          child: Center(
            child: Text(
              seat['name'],
              style: TextStyle(
                color: isActive ? textColor : inactiveTextColor,
                fontSize: width / 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void reserveDialog(context, Map<String, dynamic> seat) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('예약창'),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
        );
      },
  );
}

void alarmDialog(context, Map<String, dynamic> seat) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('알림창'),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
      );
    },
  );
}