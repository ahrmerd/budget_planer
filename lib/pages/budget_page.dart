import 'package:budget_planer/main.dart';
import 'package:budget_planer/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../objectbox.g.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final Box<Budget> budgetBox;

  @override
  void initState() {
    super.initState();
    budgetBox = store.box<Budget>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: StreamBuilder<List<Budget>>(
        stream: budgetBox
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final budgets = snapshot.data!;
          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return ListTile(
                title: Text(budget.name),
                subtitle: Text('${DateFormat('MMM d, y').format(budget.startDate)} - ${DateFormat('MMM d, y').format(budget.endDate)}'),
                trailing: Text('${budget.currentBalance.toStringAsFixed(2)} / ${budget.totalAmount.toStringAsFixed(2)}'),
                onTap: () => _showBudgetOptions(budget),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showBudgetOptions(Budget budget) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Budget'),
                onTap: () {
                  Navigator.pop(context);
                  _showBudgetDialog(context, budget: budget);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Budget'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteBudget(budget);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context, {Budget? budget}) {
    final nameController = TextEditingController(text: budget?.name ?? '');
    final amountController = TextEditingController(text: budget?.totalAmount.toString() ?? '');
    DateTime startDate = budget?.startDate ?? DateTime.now();
    DateTime endDate = budget?.endDate ?? DateTime.now().add(Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? 'Create Budget' : 'Edit Budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Budget Name'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                title: Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      startDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('End Date'),
                subtitle: Text(DateFormat('MMM d, y').format(endDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      endDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_validateInputs(nameController.text, amountController.text, startDate, endDate)) {
                final name = nameController.text.trim();
                final amount = double.parse(amountController.text);
                if (budget == null) {
                  final newBudget = Budget(
                    name: name,
                    totalAmount: amount,
                    startDate: startDate,
                    endDate: endDate,
                  );
                  budgetBox.put(newBudget);
                } else {
                  budget.name = name;
                  budget.totalAmount = amount;
                  budget.startDate = startDate;
                  budget.endDate = endDate;
                  budgetBox.put(budget);
                }
                Navigator.pop(context);
              }
            },
            child: Text(budget == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  bool _validateInputs(String name, String amount, DateTime startDate, DateTime endDate) {
    if (name.trim().isEmpty) {
      _showErrorMessage('Please enter a budget name.');
      return false;
    }
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showErrorMessage('Please enter a valid amount greater than 0.');
      return false;
    }
    if (endDate.isBefore(startDate)) {
      _showErrorMessage('End date must be after start date.');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _deleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this budget?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                budgetBox.remove(budget.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ... (rest of the BudgetPage code remains the same, just remove the store parameter from the constructor)
}