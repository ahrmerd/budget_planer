import 'package:budget_planer/models/expense.dart';
import 'package:objectbox/objectbox.dart';
import 'package:budget_planer/models/financial_goal.dart';


@Entity()
class Budget {
  int id;
  String name;
  double totalAmount;
  double currentBalance;
  DateTime startDate;
  DateTime endDate;
  final expenses = ToMany<Expense>();
  final financialGoals = ToMany<FinancialGoal>();

  Budget({
    this.id = 0,
    required this.name,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    this.currentBalance = 0,
  });

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }
   @override
  int get hashCode => id.hashCode;
}