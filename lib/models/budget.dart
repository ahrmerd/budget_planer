import 'package:objectbox/objectbox.dart';

@Entity()
class Budget {
  int id;
  String name;
  double totalAmount;
  double currentBalance;

  Budget({
    this.id = 0,
    required this.name,
    required this.totalAmount,
    this.currentBalance = 0,
  });
}
