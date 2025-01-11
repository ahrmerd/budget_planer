import 'package:flutter/material.dart';
import 'package:budget_planer/models/financial_goal.dart';
import 'package:budget_planer/main.dart';
import 'package:objectbox/objectbox.dart';
import 'package:intl/intl.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({Key? key}) : super(key: key);
  @override
  _FinancialGoalsScreenState createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  late final Box<FinancialGoal> goalBox;

  @override
  void initState() {
    super.initState();
    goalBox = store.box<FinancialGoal>();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<List<FinancialGoal>>(
          stream: goalBox
              .query()
              .watch(triggerImmediately: true)
              .map((query) => query.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final goals = snapshot.data!;
            if (goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 80,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No financial goals yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first goal',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _showGoalDetails(goal),
                    borderRadius: BorderRadius.circular(16),
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
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (goal.isAchieved)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Achieved',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmountDisplay(
                                'Current',
                                goal.currentAmount,
                                Colors.blue,
                              ),
                              _buildAmountDisplay(
                                'Target',
                                goal.targetAmount,
                                Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${goal.progressPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getRemainingTimeText(goal.targetDate),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: goal.progressPercentage / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProgressColor(goal.progressPercentage),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }

   Widget _buildAmountDisplay(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₦${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 25) return Colors.deepOrange;
    return Colors.red;
  }

   String _getRemainingTimeText(DateTime targetDate) {
    final remaining = targetDate.difference(DateTime.now());
    if (remaining.isNegative) return 'Overdue';
    if (remaining.inDays > 365) {
      final years = (remaining.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} left';
    }
    if (remaining.inDays > 30) {
      final months = (remaining.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} left';
    }
    return '${remaining.inDays} ${remaining.inDays == 1 ? 'day' : 'days'} left';
  }

  void _showGoalDetails(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Amount: \$${goal.targetAmount.toStringAsFixed(2)}'),
            Text('Current Amount: \$${goal.currentAmount.toStringAsFixed(2)}'),
            Text('Start Date: ${DateFormat('MMM d, y').format(goal.startDate)}'),
            Text('Target Date: ${DateFormat('MMM d, y').format(goal.targetDate)}'),
            Text('Progress: ${goal.progressPercentage.toStringAsFixed(1)}%'),
            if (goal.isAchieved) Text('Achieved: ${DateFormat('MMM d, y').format(goal.achievedDate!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () => _showUpdateGoalDialog(goal),
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () => _deleteGoal(goal),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    DateTime targetDate = DateTime.now().add(Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Goal Name'),
              ),
              TextField(
                controller: targetAmountController,
                decoration: InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                title: Text('Target Date'),
                subtitle: Text(DateFormat('MMM d, y').format(targetDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      targetDate = picked;
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
              if (_validateGoalInputs(nameController.text, targetAmountController.text)) {
                final newGoal = FinancialGoal(
                  name: nameController.text.trim(),
                  targetAmount: double.parse(targetAmountController.text),
                  startDate: DateTime.now(),
                  targetDate: targetDate,
                );
                goalBox.put(newGoal);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateGoalDialog(FinancialGoal goal) {
    final currentAmountController = TextEditingController(text: goal.currentAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Goal Progress'),
        content: TextField(
          controller: currentAmountController,
          decoration: InputDecoration(labelText: 'Current Amount'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_validateAmount(currentAmountController.text)) {
                goal.currentAmount = double.parse(currentAmountController.text);
                if (goal.isAchieved && goal.achievedDate == null) {
                  goal.achievedDate = DateTime.now();
                }
                goalBox.put(goal);
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this financial goal?'),
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
                goalBox.remove(goal.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateGoalInputs(String name, String targetAmount) {
    if (name.trim().isEmpty) {
      _showErrorMessage('Please enter a goal name.');
      return false;
    }
    if (targetAmount.isEmpty || double.tryParse(targetAmount) == null || double.parse(targetAmount) <= 0) {
      _showErrorMessage('Please enter a valid target amount greater than 0.');
      return false;
    }
    return true;
  }

  bool _validateAmount(String amount) {
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) < 0) {
      _showErrorMessage('Please enter a valid amount (0 or greater).');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}