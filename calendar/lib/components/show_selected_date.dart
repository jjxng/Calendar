import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/style.dart';

class ShowSelectedDate extends StatelessWidget {
  const ShowSelectedDate({
    required this.currentDate,Key? key}) : super(key: key);
  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      color: PRIMARY_COLOR,
      child: Center(
        child: Text(DateFormat('yyyy년 MM월 dd일').format(currentDate),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}