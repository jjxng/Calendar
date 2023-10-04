import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import '../database/drift_database.dart';
import '../constant/style.dart';
import '../components/show_selected_date.dart';
import '../components/schedule_bottom_sheet.dart';
import '../model/schedule_repository.dart';
import '../components/schedule_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime currentDate = DateTime.now(); // 선택된 날짜

  @override
  void initState() {
    initialize();
  }

  initialize() async {
    await GetIt.I<ScheduleRepository>().buildMarkedDateMap(currentDate);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            buildCalendarCarousel(), // 달력
            ShowSelectedDate(currentDate: currentDate), // 선택된 날짜(currentDate)
            const SizedBox(
              height: 10,
            ),
            buildEventList() // 일정조회 메서드 호출
          ],
        ),
        floatingActionButton: FloatingActionButton(
          // 일정등록 FAB 버튼 준비
          backgroundColor: NAVY_COLOR,
          child: const Icon(Icons.add),
          onPressed: () {
            scheduleInsert(context); // 입력용 sheet 호출
          },
        ),
      ),
    );
  }

  Widget buildEventList() {
    // 일정을 ListView 형태로 리턴
    return Expanded(
        child: FutureBuilder<List<Schedule>>(
      future: GetIt.I<LocalDatabase>()
          .watchSchedules(currentDate.toString().split(' ')[0]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Schedule schedule = snapshot.data![index];
              String date =
                  '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
              if (schedule.date != date) {
                return Center(child: Container(height: 0));
              }
              return Dismissible(
                key: ObjectKey(schedule.id),
                direction: DismissDirection.startToEnd,
                onDismissed: (DismissDirection direction) {
                  GetIt.I<LocalDatabase>().removeSchedule(schedule.id);
                  GetIt.I<ScheduleRepository>().buildMarkedDateMap(currentDate);
                  setState(() {});
                },
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                        onTap: () async {
                          await showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              builder: (_) =>
                                  ScheduleBottomSheet(schedule: schedule),
                              isScrollControlled: true);
                          GetIt.I<ScheduleRepository>()
                              .buildMarkedDateMap(currentDate);
                          setState(() {});
                        },
                        child: ScheduleCard(
                            date: schedule.date,
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            content: schedule.content))),
              );
            });
      },
    ));
  }

  CalendarCarousel<Event> buildCalendarCarousel() {
    TextStyle headerTextStyle = const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: PRIMARY_COLOR);
    return CalendarCarousel<Event>(
      locale: 'ko-kr',
      height: 600,
      headerTextStyle: headerTextStyle,
      weekDayMargin: const EdgeInsets.only(bottom: 10.0),
      daysHaveCircularBorder: false,
      markedDatesMap:
          GetIt.I<ScheduleRepository>().getMartkedDateMap, // mark 데이터 표시
      selectedDateTime: currentDate,
      onDayPressed: (DateTime date, List<Event> events) {
        // 날짜 변경
        setState(() {
          currentDate = date;
        });
      },
      selectedDayBorderColor: PRIMARY_COLOR,
      selectedDayButtonColor: PRIMARY_COLOR,
      todayButtonColor: GREY_COLOR,
      todayBorderColor: GREY_COLOR,
      weekdayTextStyle: const TextStyle(color: Colors.black),
    );
  }

  Future<void> scheduleInsert(BuildContext context) async {
    // 입력용 sheet 준비
    Schedule s = Schedule(
        // 빈 스케쥴 준비
        id: 0,
        content: '',
        date: currentDate.toString().split(' ')[0],
        startTime: 0900,
        endTime: 1000);
    await showModalBottomSheet(
        // 모달 형식의 시트 오픈
        context: context,
        isDismissible: true, // 다른 곳을 탭하면 닫기
        builder: (_) => ScheduleBottomSheet(schedule: s), // 빈 스케쥴 전달
        isScrollControlled: true); // 스크롤 가능
    GetIt.I<ScheduleRepository>().buildMarkedDateMap(currentDate);
    setState(() {});
  }
}
