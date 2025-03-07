import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_data_provider.dart';
import '../models/user_profile.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form fields with user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FinancialDataProvider>(context, listen: false);
      final userProfile = provider.userProfile;
      
      if (userProfile != null) {
        _nameController.text = userProfile.name;
        _incomeController.text = userProfile.monthlyIncome.toString();
      }
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }
  
  // Save user profile
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinancialDataProvider>(context, listen: false);
      final currentProfile = provider.userProfile;
      
      if (currentProfile != null) {
        final updatedProfile = UserProfile(
          id: currentProfile.id,
          name: _nameController.text,
          monthlyIncome: double.parse(_incomeController.text),
          budgetLimits: currentProfile.budgetLimits,
          hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
        );
        
        await provider.saveUserProfile(updatedProfile);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      }
    }
  }
  
  // Show dialog to edit budget limits
  void _showEditBudgetDialog() {
    final provider = Provider.of<FinancialDataProvider>(context, listen: false);
    final userProfile = provider.userProfile;
    
    if (userProfile == null) return;
    
    // Create a copy of budget limits for editing
    final Map<String, double> editedBudgetLimits = Map.from(userProfile.budgetLimits);
    
    // Controllers for each budget category
    final Map<String, TextEditingController> controllers = {};
    
    // Initialize controllers
    editedBudgetLimits.forEach((category, amount) {
      controllers[category] = TextEditingController(text: amount.toString());
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Budget Limits'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...editedBudgetLimits.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          AppTheme.getCategoryIcon(entry.key),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: AppTheme.bodyStyle,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: controllers[entry.key],
                          decoration: AppTheme.inputDecoration(
                            '',
                            prefixIcon: const Icon(Icons.attach_money, size: 16),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final newAmount = double.tryParse(value);
                            if (newAmount != null) {
                              editedBudgetLimits[entry.key] = newAmount;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
              _saveBudgetLimits(editedBudgetLimits);
              Navigator.pop(context);
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // Save updated budget limits
  Future<void> _saveBudgetLimits(Map<String, double> budgetLimits) async {
    final provider = Provider.of<FinancialDataProvider>(context, listen: false);
    final currentProfile = provider.userProfile;
    
    if (currentProfile != null) {
      final updatedProfile = UserProfile(
        id: currentProfile.id,
        name: currentProfile.name,
        monthlyIncome: currentProfile.monthlyIncome,
        budgetLimits: budgetLimits,
        hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
      );
      
      await provider.saveUserProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget limits updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinancialDataProvider>(context);
    final userProfile = provider.userProfile;
    
    if (userProfile == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Your Profile',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 24),
          
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: AppTheme.inputDecoration(
                      'Name',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Income field
                  TextFormField(
                    controller: _incomeController,
                    decoration: AppTheme.inputDecoration(
                      'Monthly Income',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your monthly income';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: AppTheme.primaryButtonStyle,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Budget limits section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Limits',
                style: AppTheme.subheadingStyle,
              ),
              TextButton.icon(
                onPressed: _showEditBudgetDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                ...userProfile.budgetLimits.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            AppTheme.getCategoryIcon(entry.key),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTheme.bodyStyle,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(entry.value),
                          style: AppTheme.subheadingStyle,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // App info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About WizzCash',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 16),
                const Text(
                  'WizzCash is a cross-platform financial analysis app with local AI-driven insights. All your data is processed locally on your device for maximum privacy.',
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your data never leaves your device',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 