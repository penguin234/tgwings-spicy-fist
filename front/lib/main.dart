import 'package:flutter/material.dart';
import './views/login.dart';

void main() {
  runApp(const BookSeat());
}

class BookSeat extends StatelessWidget {
  const BookSeat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyLoginPage()
    );
  }
}


