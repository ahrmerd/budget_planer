import 'package:budget_planer/models/budget.dart';
import 'package:budget_planer/objectbox.g.dart';
import 'package:budget_planer/store.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<Budget> budgetBox;

  @override
  void initState() {
    super.initState();
    budgetBox= store.box<Budget>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budget Planner')),
      body: StreamBuilder<List<Budget>>(
        stream: budgetBox.query().watch(triggerImmediately: true).map((query)=>query.find()),
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
                subtitle: Text('Total: \$${budget.totalAmount.toStringAsFixed(2)}'),
                trailing: Text('Balance: \$${budget.currentBalance.toStringAsFixed(2)}'),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? 'Create Budget' : 'Edit Budget'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_validateInputs(nameController.text, amountController.text)) {
                final name = nameController.text.trim();
                final amount = double.parse(amountController.text);
                if (budget == null) {
                  final newBudget = Budget(name: name, totalAmount: amount);
                  budgetBox.put(newBudget);
                } else {
                  budget.name = name;
                  budget.totalAmount = amount;
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

  bool _validateInputs(String name, String amount) {
    if (name.trim().isEmpty) {
      _showErrorMessage('Please enter a budget name.');
      return false;
    }
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showErrorMessage('Please enter a valid amount greater than 0.');
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
}