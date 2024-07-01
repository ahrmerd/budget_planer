import 'package:budget_planer/app.dart';
import 'package:budget_planer/objectbox.g.dart';
import 'package:budget_planer/store.dart';
import 'package:flutter/material.dart';




late ObjectBox objectbox;
late Store store;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  store = await openStore(); 
  runApp(const MyApp());
}
