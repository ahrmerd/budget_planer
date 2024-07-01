import 'package:budget_planer/main.dart';
import 'package:budget_planer/models/budget.dart';
import 'package:budget_planer/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final Box<Expense> expenseBox;
  late final Box<Budget> budgetBox;

  @override
  void initState() {
    super.initState();
    expenseBox = store.box<Expense>();
    budgetBox = store.box<Budget>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: StreamBuilder<List<Expense>>(
        stream: expenseBox
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.description),
                subtitle: Text('${DateFormat('MMM d, y').format(expense.date)} - ${expense.budget.target?.name ?? 'No Budget'}'),
                trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                onTap: () => _showExpenseOptions(expense),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showExpenseOptions(Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Expense'),
                onTap: () {
                  Navigator.pop(context);
                  _showExpenseDialog(context, expense: expense);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Expense'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteExpense(expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExpenseDialog(BuildContext context, {Expense? expense}) {
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    DateTime expenseDate = expense?.date ?? DateTime.now();
    Budget? selectedBudget = expense?.budget.target;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat('MMM d, y').format(expenseDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: expenseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      expenseDate = picked;
                    });
                  }
                },
              ),
              DropdownButtonFormField<Budget>(
                value: selectedBudget,
                onChanged: (Budget? newValue) {
                  setState(() {
                    selectedBudget = newValue;
                  });
                },
                items: budgetBox.getAll().map<DropdownMenuItem<Budget>>((Budget budget) {
                  return DropdownMenuItem<Budget>(
                    value: budget,
                    child: Text(budget.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Budget'),
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
              if (_validateExpenseInputs(descriptionController.text, amountController.text, selectedBudget)) {
                final description = descriptionController.text.trim();
                final amount = double.parse(amountController.text);
                
                if (expense == null) {
                  final newExpense = Expense(
                    description: description,
                    amount: amount,
                    date: expenseDate,
                  );
                  newExpense.budget.target = selectedBudget;
                  expenseBox.put(newExpense);
                } else {
                  // Update existing expense
                  expense.description = description;
                  expense.amount = amount;
                  expense.date = expenseDate;
                  expense.budget.target = selectedBudget;
                  expenseBox.put(expense);
                }

                // Update budget balance
                if (selectedBudget != null) {
                  selectedBudget!.currentBalance += amount;
                  budgetBox.put(selectedBudget!);
                }

                Navigator.pop(context);
              }
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  bool _validateExpenseInputs(String description, String amount, Budget? budget) {
    if (description.trim().isEmpty) {
      _showErrorMessage('Please enter a description.');
      return false;
    }
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showErrorMessage('Please enter a valid amount greater than 0.');
      return false;
    }
    if (budget == null) {
      _showErrorMessage('Please select a budget.');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this expense?'),
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
                // Update budget balance
                if (expense.budget.target != null) {
                  expense.budget.target!.currentBalance -= expense.amount;
                  budgetBox.put(expense.budget.target!);
                }
                expenseBox.remove(expense.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}