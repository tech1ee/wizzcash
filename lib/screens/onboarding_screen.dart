import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/financial_data_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;
  
  // User profile data
  String _name = '';
  double _monthlyIncome = 0;
  final Map<String, double> _budgetLimits = {
    'Food': 500.0,
    'Transportation': 200.0,
    'Entertainment': 150.0,
    'Housing': 1500.0,
    'Utilities': 300.0,
    'Shopping': 200.0,
    'Health': 200.0,
    'Insurance': 200.0,
  };
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage == 0) {
      // Validate name field
      if (_name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 1) {
      // Validate income field
      if (_monthlyIncome <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid monthly income')),
        );
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 2) {
      // Complete onboarding
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Skip onboarding and create a default profile
  Future<void> _skipOnboarding() async {
    // Show confirmation dialog
    final bool shouldSkip = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Onboarding?'),
        content: const Text(
          'You can set up your profile later from the Profile screen. Would you like to skip for now?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppTheme.primaryButtonStyle,
            child: const Text('Skip'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldSkip) {
      // Create a default user profile with placeholder values
      final defaultName = _name.isNotEmpty ? _name : 'User';
      final userProfile = UserProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: defaultName,
        monthlyIncome: _monthlyIncome > 0 ? _monthlyIncome : 5000.0, // Default income
        budgetLimits: _budgetLimits,
        hasCompletedOnboarding: true,
      );
      
      // Save user profile
      final provider = Provider.of<FinancialDataProvider>(context, listen: false);
      await provider.saveUserProfile(userProfile);
      
      // Navigate to home screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
  
  Future<void> _completeOnboarding() async {
    // Create user profile
    final userProfile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      monthlyIncome: _monthlyIncome,
      budgetLimits: _budgetLimits,
      hasCompletedOnboarding: true,
    );
    
    // Save user profile
    final provider = Provider.of<FinancialDataProvider>(context, listen: false);
    await provider.saveUserProfile(userProfile);
    
    // Navigate to home screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildIncomePage(),
                  _buildBudgetPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  _currentPage > 0
                      ? TextButton(
                          onPressed: _previousPage,
                          child: const Text('Back'),
                        )
                      : const SizedBox(width: 80),
                  
                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: AppTheme.primaryButtonStyle,
                    child: Text(
                      _currentPage < 2 ? 'Next' : 'Finish',
                      style: AppTheme.buttonTextStyle.copyWith(
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          
          // Welcome text
          const Text(
            'Welcome to WizzCash',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personal finance assistant with local AI-driven insights',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Name input
          TextField(
            decoration: AppTheme.inputDecoration(
              'Your Name',
              hint: 'Enter your name',
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                _name = value.trim();
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildIncomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Income icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.attach_money,
              size: 40,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Income text
          const Text(
            'Monthly Income',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Please enter your average monthly income to help us set up your budget',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Income input
          TextField(
            decoration: AppTheme.inputDecoration(
              'Monthly Income',
              hint: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _monthlyIncome = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildBudgetPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Budget Categories',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'ve set up some default budget categories for you. You can adjust these now or later.',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Budget categories list
          Expanded(
            child: ListView.builder(
              itemCount: _budgetLimits.length,
              itemBuilder: (context, index) {
                final category = _budgetLimits.keys.elementAt(index);
                final amount = _budgetLimits.values.elementAt(index);
                
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
                          AppTheme.getCategoryIcon(category),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category,
                          style: AppTheme.subheadingStyle,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          decoration: AppTheme.inputDecoration(
                            '',
                            prefixIcon: const Icon(Icons.attach_money, size: 16),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: amount.toString()),
                          onChanged: (value) {
                            final newAmount = double.tryParse(value) ?? 0;
                            setState(() {
                              _budgetLimits[category] = newAmount;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 