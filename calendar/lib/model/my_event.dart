class MyEvent {
  int? id;
  String date;
  int startTime;
  int endTime;
  String content;

  MyEvent({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.content});
}