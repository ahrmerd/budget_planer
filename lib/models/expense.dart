import 'package:budget_planer/models/budget.dart';
import 'package:objectbox/objectbox.dart';



@Entity()
class Expense {
  int id;
  String description;
  double amount;
  DateTime date;
  final budget = ToOne<Budget>();

  Expense({
    this.id = 0,
    required this.description,
    required this.amount,
    required this.date,
  });
}