import 'package:budget_planer/pages/main_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}
