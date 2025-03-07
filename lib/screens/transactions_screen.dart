import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/financial_data_provider.dart';
import '../models/transaction.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import '../utils/mock_statement_generator.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  // Form fields for adding a new transaction
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'debit';
  String _selectedCategory = 'Food';
  
  // List of available categories
  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Housing',
    'Utilities',
    'Shopping',
    'Health',
    'Insurance',
    'Income',
    'Debt Repayment',
    'Travel',
    'Education',
    'Savings',
    'Investment',
    'Electronics',
    'Other',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  // Filter transactions based on search query
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (_searchQuery.isEmpty) {
      return transactions;
    }
    
    return transactions.where((transaction) {
      return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             transaction.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // Show dialog to add a new transaction
  void _showAddTransactionDialog() {
    // Reset form fields
    _descriptionController.clear();
    _amountController.clear();
    _selectedDate = DateTime.now();
    _selectedType = 'debit';
    _selectedCategory = 'Food';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: AppTheme.inputDecoration(
                    'Description',
                    hint: 'Enter description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: AppTheme.inputDecoration(
                    'Amount',
                    hint: 'Enter amount',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: AppTheme.inputDecoration(
                      'Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      Formatters.formatMediumDate(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Transaction type
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration('Type'),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: 'debit',
                      child: Text('Expense'),
                    ),
                    DropdownMenuItem(
                      value: 'credit',
                      child: Text('Income'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      // Set default category based on type
                      if (value == 'credit') {
                        _selectedCategory = 'Income';
                      } else {
                        _selectedCategory = 'Food';
                      }
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
            onPressed: _addTransaction,
            style: AppTheme.primaryButtonStyle,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Add a new transaction
  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinancialDataProvider>(context, listen: false);
      
      final transaction = Transaction(
        id: 'tr_${DateTime.now().millisecondsSinceEpoch}',
        date: _selectedDate,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        category: _selectedCategory,
      );
      
      provider.addTransaction(transaction);
      Navigator.pop(context);
    }
  }
  
  // Import bank statement
  Future<void> _importBankStatement() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null) {
        File file = File(result.files.single.path!);
        
        // Show loading dialog with progress indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            title: Text('Processing PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 16),
                Text('Extracting transactions from your bank statement...'),
                SizedBox(height: 8),
                Text(
                  'This may take a moment as we analyze the PDF content.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
        
        // Import bank statement
        final provider = Provider.of<FinancialDataProvider>(context, listen: false);
        final transactions = await provider.importBankStatement(file);
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        if (transactions.isEmpty) {
          // Show error if no transactions were found
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No Transactions Found'),
                content: const Text('We couldn\'t find any transactions in the provided PDF. Make sure you\'re uploading a bank statement with transaction data.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Show success dialog with transaction details
          if (mounted) {
            _showImportSuccessDialog(transactions);
          }
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show detailed error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Failed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('We encountered an error while processing your bank statement:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Suggestions:'),
                const SizedBox(height: 4),
                const Text('• Make sure the file is a valid PDF'),
                const Text('• Check if the PDF is password protected'),
                const Text('• Try using a different statement format if available'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  // Show import success dialog with transaction details
  void _showImportSuccessDialog(List<Transaction> transactions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Container(
          constraints: const BoxConstraints(
            maxHeight: 400,
          ),
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Successfully imported ${transactions.length} transactions.'),
              const SizedBox(height: 16),
              const Text('Imported Transactions:', style: AppTheme.subheadingStyle),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        transaction.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${Formatters.formatMediumDate(transaction.date)} • ${transaction.category}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        Formatters.formatTransactionAmount(
                          transaction.amount,
                          transaction.type,
                        ),
                        style: TextStyle(
                          color: AppTheme.getTransactionColor(transaction.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showEditCategoryDialog(transaction),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Switch to the transactions tab
              _tabController.animateTo(0);
            },
            child: const Text('View All Transactions'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  // Show dialog to edit transaction category
  void _showEditCategoryDialog(Transaction transaction) {
    String selectedCategory = transaction.category;
    
    // Get categories list from theme
    final categories = AppTheme.categories;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description,
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.formatTransactionAmount(
                  transaction.amount,
                  transaction.type,
                ),
                style: TextStyle(
                  color: AppTheme.getTransactionColor(transaction.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Category:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return RadioListTile<String>(
                      title: Text(category),
                      value: category,
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    );
                  },
                ),
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
              // Create updated transaction with new category
              final updatedTransaction = Transaction(
                id: transaction.id,
                date: transaction.date,
                description: transaction.description,
                amount: transaction.amount,
                type: transaction.type,
                category: selectedCategory,
              );
              
              // Update the transaction
              final provider = Provider.of<FinancialDataProvider>(context, listen: false);
              provider.updateTransaction(updatedTransaction);
              
              Navigator.pop(context);
              Navigator.pop(context);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction category updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              // Refresh the transactions list
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Generate and import a mock statement for testing
  Future<void> _generateAndImportMockStatement() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Generating Test Statement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating a mock bank statement for testing...'),
            ],
          ),
        ),
      );
      
      // Generate the mock statement
      final mockPdfFile = await MockStatementGenerator.generateMockBankStatement();
      
      // Close the loading dialog
      if (mounted) Navigator.pop(context);
      
      // Import the mock statement
      if (mounted) {
        // Show loading dialog for importing
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            title: Text('Processing PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 16),
                Text('Extracting transactions from your mock statement...'),
              ],
            ),
          ),
        );
        
        // Import bank statement
        final provider = Provider.of<FinancialDataProvider>(context, listen: false);
        final transactions = await provider.importBankStatement(mockPdfFile);
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        // Show success dialog with imported transactions
        if (mounted && transactions.isNotEmpty) {
          _showImportSuccessDialog(transactions);
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to generate or import mock statement: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinancialDataProvider>(context);
    final transactions = provider.transactions;
    final filteredTransactions = _filterTransactions(transactions);
    
    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All Transactions'),
            Tab(text: 'Import Statement'),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All transactions tab
              Column(
                children: [
                  // Search and add buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Search field
                        Expanded(
                          child: TextField(
                            decoration: AppTheme.inputDecoration(
                              'Search',
                              hint: 'Search transactions',
                              prefixIcon: const Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Add button
                        FloatingActionButton(
                          onPressed: _showAddTransactionDialog,
                          backgroundColor: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Transactions list
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? const Center(
                            child: Text('No transactions found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionCard(
                                transaction: filteredTransactions[index],
                                onTap: () {
                                  // Show transaction details
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
              
              // Import statement tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Import icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          size: 50,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Import text
                      const Text(
                        'Import Bank Statement',
                        style: AppTheme.headingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload your bank statement in PDF format to automatically import transactions.',
                        style: AppTheme.bodyStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Import button
                      ElevatedButton.icon(
                        onPressed: _importBankStatement,
                        style: AppTheme.primaryButtonStyle.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select PDF File'),
                      ),
                      const SizedBox(height: 12),
                      
                      // Generate mock statement button (for testing)
                      OutlinedButton.icon(
                        onPressed: _generateAndImportMockStatement,
                        style: AppTheme.outlineButtonStyle.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Generate Test Statement'),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Features list
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Automatic transaction extraction'),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Smart category detection'),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('100% private - processing happens on your device'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note text
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Note: Your data is processed locally on your device for privacy.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 