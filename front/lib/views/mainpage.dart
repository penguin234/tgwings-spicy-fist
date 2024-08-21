import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgthon/views/QRpage.dart';
import 'package:tgthon/views/crowdExpectPage.dart';
import 'package:tgthon/views/myPage.dart';
import 'package:tgthon/views/seatReservePage.dart';
import '../theme.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const MainPage(this.data, {super.key});

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
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
            Icons.logout,
            color: Colors.black,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
          Center(
            child: Container(
              width: buttonSize * 2, // 전체 너비 계산
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildMenuButton(
                        context,
                        Icons.qr_code,
                        '이용증',
                        buttonTextStyle,
                        buttonSize * 0.6,
                            () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRpage(widget.data),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 40),
                      buildMenuButton(
                        context,
                        Icons.event_seat,
                        '좌석 예약',
                        buttonTextStyle,
                        buttonSize * 0.6,
                            () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SeatReservePage(widget.data),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // 1행과 2행 사이의 여백
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildMenuButton(
                        context,
                        Icons.manage_search,
                        '예상 혼잡도',
                        buttonTextStyle,
                        buttonSize * 0.6,
                            () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CrowdExpectPage(widget.data),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 40),
                      buildMenuButton(
                        context,
                        Icons.person,
                        '내 정보',
                        buttonTextStyle,
                        buttonSize * 0.6,
                            () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyPage(widget.data),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(BuildContext context, IconData icon, String title, TextStyle textStyle, double size, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: size, // 버튼의 높이 설정
          width: size, // 버튼의 너비 설정
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: size * 0.5, // 아이콘 크기 설정
              color: khblue,
            ),
            onPressed: onPressed, // 버튼 클릭 시 동작
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: textStyle,
        ),
      ],
    );
  }
}
