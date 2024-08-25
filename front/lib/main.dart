import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './views/login.dart';

void main() {
  runApp(const BookSeat());
}

class BookSeat extends StatelessWidget {
  const BookSeat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyLoginPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('ko','KR')
      ],
    );
  }
}


