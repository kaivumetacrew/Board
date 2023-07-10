import 'package:board/ui/board/board_db.dart';
import 'package:board/ui/board_list.dart';
import 'package:board/ui/sensor/sensor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';

bool hadInitHive = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          color: Colors.blue, //<-- SEE HERE
        ),
      ),
      //localizationsDelegates: AppLocalizations.localizationsDelegates,
      localizationsDelegates: const [
        //AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Spanish
      ],
      home:  BoardListPage(),
    );
  }
}

Future initHive() async {
  if (!hadInitHive) {
    hadInitHive = true;
    await Hive.initFlutter();
    Hive.registerAdapter(BoardDataDBOAdapter());
    Hive.registerAdapter(BoardItemDBOAdapter());
  }
}
