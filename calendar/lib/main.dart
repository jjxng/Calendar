import 'package:calendar/model/schedule_repository.dart';
import 'package:calendar/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'database/drift_database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:calendar/database/drift_database.dart';

void main() {
  final LocalDatabase database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);       // database 상태관리

  final repository = ScheduleRepository();
  GetIt.I.registerSingleton<ScheduleRepository>(repository);
  
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [                   // 국제화
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ko', 'KO'),
      ],
      home: HomeScreen()
    )
  );
}