import 'package:budget_planer/app.dart';
import 'package:budget_planer/models/budget.dart';
import 'package:budget_planer/models/expense.dart';
import 'package:budget_planer/objectbox.g.dart';
import 'package:budget_planer/store.dart';
import 'package:flutter/material.dart';




late ObjectBox objectbox;
late Store store;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  store = await openStore();
  updateBudgetBalances(store);
  runApp(const MyApp());
}


void updateBudgetBalances(Store store) {
  final budgetBox = store.box<Budget>();
  final expenseBox = store.box<Expense>();
  
  // Get all budgets
  final budgets = budgetBox.getAll();
  
  // Update each budget
  for (final budget in budgets) {
    // Get all expenses for this budget
    final expenses = expenseBox
        .query(Expense_.budget.equals(budget.id))
        .build()
        .find();
    
    // Calculate total expenses
    final totalExpenses = expenses.fold<double>(
      0, 
      (sum, expense) => sum + expense.amount
    );
    
    // Update budget balance
    budget.currentBalance = totalExpenses;
    
    // Save updated budget
    budgetBox.put(budget);
  }
}
 

