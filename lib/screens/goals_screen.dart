import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_data_provider.dart';
import '../models/financial_goal.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Form fields for adding a new goal
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  String _selectedPriority = 'medium';
  String _selectedCategory = 'Savings';
  
  // List of available categories
  final List<String> _categories = [
    'Savings',
    'Travel',
    'Housing',
    'Electronics',
    'Debt Repayment',
    'Education',
    'Investment',
    'Retirement',
    'Emergency Fund',
    'Vehicle',
    'Other',
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }
  
  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }
  
  // Show dialog to add a new goal
  void _showAddGoalDialog() {
    // Reset form fields
    _titleController.clear();
    _targetAmountController.clear();
    _currentAmountController.clear();
    _targetDate = DateTime.now().add(const Duration(days: 365));
    _selectedPriority = 'medium';
    _selectedCategory = 'Savings';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Financial Goal'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: AppTheme.inputDecoration(
                    'Goal Title',
                    hint: 'Enter goal title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Target amount field
                TextFormField(
                  controller: _targetAmountController,
                  decoration: AppTheme.inputDecoration(
                    'Target Amount',
                    hint: 'Enter target amount',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current amount field
                TextFormField(
                  controller: _currentAmountController,
                  decoration: AppTheme.inputDecoration(
                    'Current Amount',
                    hint: 'Enter current amount',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a current amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Target date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: AppTheme.inputDecoration(
                      'Target Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      Formatters.formatMediumDate(_targetDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority dropdown
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration('Priority'),
                  value: _selectedPriority,
                  items: const [
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('High Priority'),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text('Medium Priority'),
                    ),
                    DropdownMenuItem(
                      value: 'low',
                      child: Text('Low Priority'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Category dropdown
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration('Category'),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addGoal,
            style: AppTheme.primaryButtonStyle,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Add a new goal
  void _addGoal() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinancialDataProvider>(context, listen: false);
      
      final goal = FinancialGoal(
        id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        targetDate: _targetDate,
        priority: _selectedPriority,
        category: _selectedCategory,
      );
      
      provider.addFinancialGoal(goal);
      Navigator.pop(context);
    }
  }
  
  // Show dialog to update goal progress
  void _showUpdateProgressDialog(FinancialGoal goal) {
    final _progressController = TextEditingController(text: goal.currentAmount.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ${Formatters.formatCurrency(goal.targetAmount)}',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _progressController,
              decoration: AppTheme.inputDecoration(
                'Current Amount',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(_progressController.text);
              if (newAmount != null) {
                _updateGoalProgress(goal, newAmount);
                Navigator.pop(context);
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  // Update goal progress
  void _updateGoalProgress(FinancialGoal goal, double newAmount) {
    final provider = Provider.of<FinancialDataProvider>(context, listen: false);
    
    final updatedGoal = FinancialGoal(
      id: goal.id,
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: newAmount,
      targetDate: goal.targetDate,
      priority: goal.priority,
      category: goal.category,
    );
    
    provider.updateFinancialGoal(updatedGoal);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinancialDataProvider>(context);
    final goals = provider.financialGoals;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Financial Goals',
                style: AppTheme.headingStyle,
              ),
              FloatingActionButton(
                onPressed: _showAddGoalDialog,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your progress towards financial freedom',
            style: AppTheme.captionStyle,
          ),
          const SizedBox(height: 24),
          
          // Goals list
          Expanded(
            child: goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 64,
                          color: AppTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No financial goals yet',
                          style: AppTheme.subheadingStyle,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the + button to add your first goal',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => _showUpdateProgressDialog(goals[index]),
                        child: GoalCard(goal: goals[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 