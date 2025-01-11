import 'package:budget_planer/pages/budget_page.dart';
import 'package:budget_planer/pages/expenses_page.dart';
import 'package:budget_planer/pages/financial_goals_screen.dart';
import 'package:budget_planer/pages/home_screen.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: MainPage(),
      home:  HomeScreen(),
      routes: {
        '/home': (context) =>  HomeScreen(),
        '/budgets': (context) => const BudgetPage(),
        '/expenses': (context) => const ExpensePage(),
        '/financial_goals': (context) => const FinancialGoalsScreen(),
      },
    );
  }
}
