import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgthon/views/QRpage.dart';
import 'package:tgthon/views/crowdExpectPage.dart';
import 'package:tgthon/views/myPage.dart';
import 'package:tgthon/views/seatReservePage.dart';
import '../theme.dart';

class ReadingRoom extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReadingRoom(this.data, {super.key});

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
    final buttonTextStyle = GoogleFonts.notoSans(
      fontSize: 20,
      color: Colors.white70,
    );

    final double buttonSize = MediaQuery.of(context).size.width * 0.5; // 버튼 크기 계산

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
          '열람실',
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
    );
  }
}