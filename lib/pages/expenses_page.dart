import 'package:budget_planer/main.dart';
import 'package:budget_planer/models/budget.dart';
import 'package:budget_planer/models/expense.dart';
import 'package:budget_planer/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final Box<Expense> expenseBox;
  late final Box<Budget> budgetBox;
  final currencyFormat = NumberFormat.currency(locale: 'en-NG',name: 'NGN');

  // Add expense categories with icons
  final Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Shopping': Icons.shopping_bag,
    'Transportation': Icons.directions_car,
    'Bills & Utilities': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.medical_services,
    'Travel': Icons.flight,
    'Other': Icons.more_horiz,
  };

  

  @override
  void initState() {
    super.initState();
    expenseBox = store.box<Expense>();
    budgetBox = store.box<Budget>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            
          ],
        ),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: expenseBox
            .query()
            .order(Expense_.date, flags: Order.descending)
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          return expenses.isEmpty
              ? _buildEmptyState()
              : _buildExpensesList(expenses);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    String? currentDate;
    double totalAmount = expenses.fold(0, (sum, expense) => sum + expense.amount);

    return Column(
      children: [
        // Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(totalAmount),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final expenseDate = DateFormat('MMM d, y').format(expense.date);
              
              // Add date header if it's a new date
              final dateHeader = currentDate != expenseDate
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        expenseDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : null;
              currentDate = expenseDate;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dateHeader != null) dateHeader,
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _showExpenseOptions(expense),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                categoryIcons[expense.category ?? 'Other'] ?? Icons.receipt,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expense.budget.target?.name ?? 'No Budget',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(expense.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

   void _showExpenseOptions(Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                ),
                title: const Text('Edit Expense'),
                onTap: () {
                  Navigator.pop(context);
                  _showExpenseDialog(context, expense: expense);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Delete Expense'),
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
    String? selectedCategory = expense?.category ?? categoryIcons.keys.first;

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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₦',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categoryIcons.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(categoryIcons[category]),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM d, y').format(expenseDate)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<Budget>(
                value: selectedBudget,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  border: OutlineInputBorder(),
                ),
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
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateExpenseInputs(descriptionController.text, amountController.text, selectedBudget)) {
                final description = descriptionController.text.trim();
                final amount = double.parse(amountController.text);
                
                if (expense == null) {
                  final newExpense = Expense(
                    description: description,
                    amount: amount,
                    date: expenseDate,
                    category: selectedCategory,
                  );
                  newExpense.budget.target = selectedBudget;
                  expenseBox.put(newExpense);
                } else {
                  expense.description = description;
                  expense.amount = amount;
                  expense.date = expenseDate;
                  expense.category = selectedCategory;
                  expense.budget.target = selectedBudget;

                  //need to remove from old budget
                  if (expense.budget.target != null) {
                    expense.budget.target!.currentBalance -= expense.amount;
                    budgetBox.put(expense.budget.target!);
                  }
                  expenseBox.put(expense);
                }

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
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
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