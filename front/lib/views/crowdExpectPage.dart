import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; // khred 색상 사용을 위한 import

class CrowdExpectPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const CrowdExpectPage(this.data, {super.key});

  @override
  _CrowdExpectPageState createState() {
    return _CrowdExpectPageState();
  }
}

class _CrowdExpectPageState extends State<CrowdExpectPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = GoogleFonts.notoSans(
      //fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white70
    );

    final double buttonSize = MediaQuery
        .of(context)
        .size
        .width * 0.4; // 버튼 크기 계산

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
    );
  }
}