// import 'package:calendar/constant/style.dart';
import 'package:flutter/material.dart';
import '../constant/style.dart';
import '../database/drift_database.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet(
      {required this.schedule, // 매개변수 : Schedule
      Key? key})
      : super(key: key);
  final Schedule schedule;

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheet();
}

class _ScheduleBottomSheet extends State<ScheduleBottomSheet> {
  late String currentDate; // 현재날짜 저장
  late final int id;

  DateTime startTimeSelected = DateTime.now(); // 시작시간 저장
  DateTime endTimeSelected = DateTime.now(); // 종료시간 저장

  @override
  void initState() {
    super.initState();
    currentDate = widget.schedule.date; // currentDate 초기화
    content = widget.schedule.content;
    controller = TextEditingController(text: content);
  }

  int? startTime; // 시작시간
  int? endTime; // 종료시간
  String? content; // 일정내용
  TextEditingController? controller; // 내용 컨트롤러

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // 키보드 높이
    Size size = MediaQuery.of(context).size;

    return Container(
        height: size.height / 2 + bottomInset, // 시트 높이 + 키보드 높이
        color: Colors.white,
        child: Padding(
          padding:
              EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSelectDate(), // 날짜변경 버튼
              Row(children: [
                buildSelectTime(context, '시작시간', widget.schedule.startTime),
                const Spacer(),
                buildSelectTime(context, '종료시간', widget.schedule.endTime),
              ]),
              const SizedBox(
                width: 16,
              ),
              const Text(
                '내용',
                style: textStyle,
              ),
              buildContent(), // 내용 입력용 텍스트필드
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          // 취소 버튼
                          style: ElevatedButton.styleFrom(
                              backgroundColor: PRIMARY_COLOR),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소')),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                          // 저장 버튼
                          style: ElevatedButton.styleFrom(
                              backgroundColor: PRIMARY_COLOR),
                          onPressed: () {
                            onSaveSchedule(widget.schedule.id); // 일정저장 메서드 호출
                          },
                          child: const Text('입력')),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void onSaveSchedule(int id) {
    // 매개변수 id
    if (content == null || content!.isEmpty) return;

    startTime = startTimeSelected.hour * 100 + startTimeSelected.minute; // 시작시간
    endTime = endTimeSelected.hour * 100 + endTimeSelected.minute; // 종료시간

    id == 0
        ? GetIt.I<LocalDatabase>().createSchedule(// 데이터베이스에 저장
            SchedulesCompanion(
                startTime: Value(startTime!),
                endTime: Value(endTime!),
                content: Value(content!),
                date: Value(currentDate)))
        : GetIt.I<LocalDatabase>().updateSchedule(
            Schedule(
                id: id,
                startTime: startTime!,
                endTime: endTime!,
                content: content!,
                date: currentDate),
          );

    // for test
    Future<List<Schedule>> snapshot = GetIt.I<LocalDatabase>()
        .monthSelectSchedules('2023-09-01', '2023-09-30');
    snapshot.then((value) => print(value));

    Navigator.of(context).pop();
  }

  Widget buildSelectDate() {
    return Row(children: [
      const Text(
        '날짜',
        style: titleStyle,
      ),
      const SizedBox(
        width: 8,
      ),
      Expanded(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SKYBLUE_COLOR),
            onPressed: () {
              selectDate(context); // 날짜 선택 메서드 호출
            },
            child: Text(currentDate, style: textStyle)),
      ),
    ]);
  }

  Future<void> selectDate(BuildContext context) async {
    // 날짜선택 후 currentDate에 저장

    DateTime convertDate = DateTime(
      int.parse(currentDate.split('-')[0]),
      int.parse(currentDate.split('-')[1]),
      int.parse(currentDate.split('-')[2]),
    );

    final DateTime? picked = await showDatePicker(
      // 날짜선택 dialog open
      context: context,
      locale: const Locale('ko', 'KR'), // 한글 dialog 요청
      initialDate: convertDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != convertDate) {
      setState(() {
        currentDate = picked.toString().split(' ')[0];
      });
    }

    int startHour = (widget.schedule.startTime ~/ 100);
    int startMin = (widget.schedule.startTime % 100);
    int endHour = (widget.schedule.endTime ~/ 100);
    int endMin = (widget.schedule.endTime % 100);
    startTimeSelected = DateTime(
        int.parse(currentDate.split('-')[0]),
        int.parse(currentDate.split('-')[1]),
        int.parse(currentDate.split('-')[2]),
        startHour,
        startMin);
    endTimeSelected = DateTime(
        int.parse(currentDate.split('-')[0]),
        int.parse(currentDate.split('-')[1]),
        int.parse(currentDate.split('-')[2]),
        endHour,
        endMin);
  }

  Widget buildSelectTime(BuildContext context, String label, int time) {
    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textStyle),
        SizedBox(
          width: size.width / 2.5,
          child: ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                if (label == '시작시간') {
                  openTimePickerSheet(context, true);
                } else {
                  openTimePickerSheet(context, false);
                }
              },
              child: label == '시작시간'
                  // ? Text('$startHour:$startMin', style: textStyle)
                  // : Text('$endHour:$endMin', style: textStyle)

                  ? Text(
                      '${startTimeSelected.hour.toString().padLeft(2, '0')}'
                      ':'
                      '${startTimeSelected.minute.toString().padLeft(2, '0')}',
                      style: textStyle)
                  : Text(
                      '${endTimeSelected.hour.toString().padLeft(2, '0')}'
                      ':'
                      '${endTimeSelected.minute.toString().padLeft(2, '0')}',
                      style: textStyle)),
        ),
      ],
    );
  }

  void openTimePickerSheet(BuildContext context, bool isStart) async {
    final selectTime = await TimePicker.show<DateTime?>(
        context: context,
        sheet: TimePickerSheet(
          sheetTitle: '오늘의 일정',
          minuteTitle: '분',
          hourTitle: '시간',
          saveButtonText: '저장',
          initialDateTime: startTimeSelected,
          sheetCloseIconColor: Colors.black,
          wheelNumberSelectedStyle: const TextStyle(fontSize: 20),
          saveButtonColor: PRIMARY_COLOR,
          sheetTitleStyle: const TextStyle(color: Colors.blue, fontSize: 12),
          hourTitleStyle: const TextStyle(color: Colors.blue, fontSize: 12),
          minuteTitleStyle: const TextStyle(color: Colors.blue, fontSize: 12),
        ));

    if (selectTime != null) {
      setState(() {
        if (isStart) {
          startTimeSelected = selectTime;
          endTimeSelected = selectTime;
        } else {
          if (selectTime.isAfter(startTimeSelected)) {
            endTimeSelected = selectTime;
          } else {
            endTimeSelected = selectTime;
          }
        }
      });
    }
  }

  Widget buildContent() {
    return Expanded(
      flex: 1,
      child: TextFormField(
        expands: true,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: controller,
        onChanged: (String? val) {
          setState(() {
            content = val; // 변경한 내용을 content에 저장
          });
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
