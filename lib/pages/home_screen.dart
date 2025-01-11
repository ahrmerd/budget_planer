import 'package:budget_planer/models/budget.dart';
import 'package:budget_planer/models/expense.dart';
import 'package:budget_planer/models/financial_goal.dart';
import 'package:budget_planer/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  
  final Box<Expense> expenseBox = store.box<Expense>();
  final Box<Budget> budgetBox = store.box<Budget>();
  final Box<FinancialGoal> goalBox = store.box<FinancialGoal>();
  final currencyFormat = NumberFormat.currency(symbol: '₦');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Budget>>(
        stream: budgetBox
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final budgets = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (budgets.isNotEmpty) _buildFinancialSummary(budgets),
                      const SizedBox(height: 16),
                      _buildQuickAccess(context),
                      const SizedBox(height: 16),
                      _buildRecentExpenses(),
                      const SizedBox(height: 16),
                      _buildGoalsProgress(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Budget Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(List<Budget> budgets) {
    final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.totalAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.currentBalance);
    final remaining = totalBudget - totalSpent;
    final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Budget',
                  totalBudget,
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Spent',
                  totalSpent,
                  Icons.shopping_cart,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Remaining',
                  remaining,
                  Icons.savings,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Usage',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(spentPercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(spentPercentage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: spentPercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(spentPercentage),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAccessButton(
                  context,
                  'Expenses',
                  Icons.receipt_long,
                  Colors.purple,
                  '/expenses',
                ),
                _buildQuickAccessButton(
                  context,
                  'Budgets',
                  Icons.account_balance_wallet,
                  Colors.blue,
                  '/budgets',
                ),
                _buildQuickAccessButton(
                  context,
                  'Goals',
                  Icons.flag,
                  Colors.green,
                  '/financial_goals',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return StreamBuilder<List<Expense>>(
      stream: expenseBox.query().order(Expense_.date, flags: Order.descending).watch(triggerImmediately: true).map((query) {
        // query. ().limit = 5;
        return query.find();
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final expenses = snapshot.data!;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/expenses');

                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                if (expenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No recent expenses',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...expenses.map((expense) => _buildExpenseItem(expense)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMM d, y').format(expense.date),
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
    );
  }

  Widget _buildGoalsProgress() {
    return StreamBuilder<List<FinancialGoal>>(
      stream: goalBox
          .query()
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final goals = snapshot.data!;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Financial Goals',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/financial_goals');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                if (goals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No goals set',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...goals.map((goal) => _buildGoalItem(goal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalItem(FinancialGoal goal) {
    final progress = goal.progressPercentage / 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.7) return Colors.green;
    if (progress < 0.9) return Colors.orange;
    return Colors.red;
  }
}