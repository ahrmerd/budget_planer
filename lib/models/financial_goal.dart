import 'package:objectbox/objectbox.dart';
import 'package:budget_planer/models/budget.dart';

@Entity()
class FinancialGoal {
  int id;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime startDate;
  DateTime targetDate;
  @Property(type: PropertyType.date)
  DateTime? achievedDate;
  final budget = ToOne<Budget>();

  FinancialGoal({
    this.id = 0,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.startDate,
    required this.targetDate,
    this.achievedDate,
  });

  bool get isAchieved => currentAmount >= targetAmount;
  double get progressPercentage => (currentAmount / targetAmount * 100).clamp(0, 100);
}