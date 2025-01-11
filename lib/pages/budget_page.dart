import 'package:budget_planer/main.dart';
import 'package:budget_planer/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../objectbox.g.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final Box<Budget> budgetBox;
  final currencyFormat = NumberFormat.currency(locale: 'en-NG',name: 'NGN');

  @override
  void initState() {
    super.initState();
    budgetBox = store.box<Budget>();
  }
  
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'My Budgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: budgetBox
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final budgets = snapshot.data!;
          return budgets.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    return _buildBudgetCard(budget);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBudgetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Budget'),
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
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start tracking',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final progress = budget.currentBalance / budget.totalAmount;
    final remainingAmount = budget.totalAmount - budget.currentBalance;
    final progressColor = progress < 0.7 
        ? Colors.green 
        : progress < 0.9 
            ? Colors.orange 
            : Colors.red;

    final daysLeft = budget.endDate.difference(DateTime.now()).inDays;
    final dailyBudget = remainingAmount / (daysLeft > 0 ? daysLeft : 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showBudgetOptions(budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}% Used',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress and remaining amount section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Remaining',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(budget.currentBalance),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(remainingAmount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: remainingAmount > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            minHeight: 17,
                          ),
                          if (progress > 0.1)
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${currencyFormat.format(budget.currentBalance)} of ${currencyFormat.format(budget.totalAmount)}',
                                  style: const TextStyle(
                                    color: Colors.brown,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Daily budget and date range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Budget',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        currencyFormat.format(dailyBudget),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        daysLeft > 0 ? "$daysLeft days left" : "Ended",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM d').format(budget.startDate)} - ${DateFormat('MMM d').format(budget.endDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
                leading: const Icon(Icons.edit),
                title: const Text('Edit Budget'),
                onTap: () {
                  Navigator.pop(context);
                  _showBudgetDialog(context, budget: budget);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Budget'),
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
    DateTime endDate = budget?.endDate ?? DateTime.now().add(const Duration(days: 30));

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
                decoration: const InputDecoration(labelText: 'Budget Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
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
                title: const Text('End Date'),
                subtitle: Text(DateFormat('MMM d, y').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
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
            child: const Text('Cancel'),
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
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this budget?'),
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