import 'package:flutter/material.dart';
import '../constant/style.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.content,
    Key? key}) : super(key: key);
  final String date;
  final int startTime;
  final int endTime;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: PRIMARY_COLOR),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _Time(startTime: startTime, endTime: endTime),
              const SizedBox(width: 16,),
              _Content(content: content, date: date),
              const SizedBox(width: 16,),
            ],
          ),
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({
    required this.startTime,
    required this.endTime,
    Key? key}) : super(key: key);
  final int startTime;
  final int endTime;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: PRIMARY_COLOR,
      fontSize: 16
    );
    int startHour = (startTime ~/ 100);
    int startMin = (startTime % 100);
    int endHour = (endTime ~/ 100);
    int endMin = (endTime % 100);

    return Column(
      children: [
        Text('${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}', style: textStyle),
        Text('${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}', style: textStyle.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.content, required this.date, Key? key}) : super(key: key);
  final String content;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(content, style: const TextStyle(fontSize: 16)));
  }
}