import 'package:budget_planer/models/expense.dart';
import 'package:objectbox/objectbox.dart';


@Entity()
class Budget {
  int id;
  String name;
  double totalAmount;
  double currentBalance;
  DateTime startDate;
  DateTime endDate;
  final expenses = ToMany<Expense>();

  Budget({
    this.id = 0,
    required this.name,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    this.currentBalance = 0,
  });
}