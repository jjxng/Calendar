import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:get_it/get_it.dart';
import '../constant/style.dart';
import '../database/drift_database.dart';
import '../model/my_event.dart';

class ScheduleRepository extends ChangeNotifier {
  EventList<Event> markedDateMap = EventList(events: {});
  List<MyEvent> myEventList = List.empty(growable: true);

  EventList<Event> get getMartkedDateMap => markedDateMap;
  List<MyEvent> get getMyEventList => myEventList;

  Widget eventMark = Container(
    margin: const EdgeInsets.symmetric(horizontal: 1.0),
    color: MARK_COLOR, height: 5.0, width: 5.0,
  );

  Future<void> buildMarkedDateMap(DateTime date) async {
    markedDateMap = EventList(events: {});
    myEventList = List.empty(growable: true);
    List<Schedule> snapshot;

    final today = date;
    final firstDay = DateTime(today.year, today.month - 1, today.day)
      .toString().split(' ')[0];
    final lastDay = DateTime(today.year, today.month + 1, today.day)
      .toString().split(' ')[0];
    
    snapshot = await GetIt.I<LocalDatabase>().monthSelectSchedules(firstDay, lastDay);

    for (Schedule s in snapshot) {
      print('$s');
      setMarkedDateMap(s.date);
      setMyEventList(s);
    }
    notifyListeners();
  }

  setMarkedDateMap(String date) async {
    List dateSplit = date.split('-');
    DateTime eventDate = DateTime(
      int.parse(dateSplit[0]),
      int.parse(dateSplit[1]),
      int.parse(dateSplit[2]));
    markedDateMap.add(
      eventDate, Event(date: eventDate, dot: eventMark)
    );
  }

  setMyEventList(Schedule s) {
    MyEvent event = MyEvent(
      date: s.date,
      startTime: s.startTime,
      endTime: s.endTime,
      content: s.content);
    myEventList.add(event);
  }
}