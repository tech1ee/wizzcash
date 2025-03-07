import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/transaction.dart' as app_models;
import '../models/financial_goal.dart';
import '../models/recommendation.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/pdf_parser_service.dart';
import '../services/analytics_service.dart';

class FinancialDataProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final PDFParserService _pdfParserService = PDFParserService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  UserProfile? _userProfile;
  List<app_models.Transaction> _transactions = [];
  List<FinancialGoal> _financialGoals = [];
  List<Recommendation> _recommendations = [];
  Map<String, dynamic> _insights = {};
  Map<String, double> _forecast = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  UserProfile? get userProfile => _userProfile;
  List<app_models.Transaction> get transactions => _transactions;
  List<FinancialGoal> get financialGoals => _financialGoals;
  List<Recommendation> get recommendations => _recommendations;
  Map<String, dynamic> get insights => _insights;
  Map<String, double> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadUserProfile();
      await _loadTransactions();
      await _loadFinancialGoals();
      await _generateInsights();
      await _generateRecommendations();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize data: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    _setLoading(true);
    try {
      if (_userProfile == null) {
        await _databaseService.insertUserProfile(profile);
      } else {
        await _databaseService.updateUserProfile(profile);
      }
      _userProfile = profile;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save user profile: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await _databaseService.getUserProfile();
      
      // If no profile exists, create a default one
      if (_userProfile == null) {
        _userProfile = UserProfile.createDefault();
        await _databaseService.insertUserProfile(_userProfile!);
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
      print(_errorMessage);
      // If we can't load the profile, create a default one
      _userProfile = UserProfile.createDefault();
    }
  }
  
  // Add transaction
  Future<void> addTransaction(app_models.Transaction transaction) async {
    _setLoading(true);
    try {
      await _databaseService.insertTransaction(transaction);
      _transactions.add(transaction);
      await _generateInsights();
      await _generateRecommendations();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add transaction: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Update transaction
  Future<void> updateTransaction(app_models.Transaction transaction) async {
    _setLoading(true);
    try {
      await _databaseService.updateTransaction(transaction);
      
      // Replace the transaction in the list
      int index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
      
      await _generateInsights();
      await _generateRecommendations();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      await _generateInsights();
      await _generateRecommendations();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load transactions
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _databaseService.getTransactions();
      // If no transactions exist in the database, load mock data
      if (_transactions.isEmpty) {
        await _loadMockTransactions();
      }
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
      print(_errorMessage);
      // If loading fails, try to use mock data
      await _loadMockTransactions();
    }
  }
  
  // Import PDF bank statement
  Future<List<app_models.Transaction>> importBankStatement(File pdfFile) async {
    _setLoading(true);
    try {
      bool isValid = await _pdfParserService.isValidBankStatement(pdfFile);
      
      if (!isValid) {
        throw Exception('Invalid bank statement format');
      }
      
      List<app_models.Transaction> newTransactions = await _pdfParserService.parseBankStatement(pdfFile);
      
      // Add all new transactions to the database
      for (var transaction in newTransactions) {
        await _databaseService.insertTransaction(transaction);
      }
      
      // Update local list
      _transactions.addAll(newTransactions);
      
      // Regenerate insights and recommendations
      await _generateInsights();
      await _generateRecommendations();
      
      _errorMessage = null;
      notifyListeners();
      return newTransactions;
    } catch (e) {
      _errorMessage = 'Failed to import bank statement: $e';
      print(_errorMessage);
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Add financial goal
  Future<void> addFinancialGoal(FinancialGoal goal) async {
    _setLoading(true);
    try {
      await _databaseService.insertFinancialGoal(goal);
      _financialGoals.add(goal);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add financial goal: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Update financial goal
  Future<void> updateFinancialGoal(FinancialGoal goal) async {
    _setLoading(true);
    try {
      await _databaseService.updateFinancialGoal(goal);
      
      // Replace the goal in the list
      int index = _financialGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _financialGoals[index] = goal;
      }
      
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update financial goal: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete financial goal
  Future<void> deleteFinancialGoal(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteFinancialGoal(id);
      _financialGoals.removeWhere((g) => g.id == id);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete financial goal: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load financial goals
  Future<void> _loadFinancialGoals() async {
    try {
      _financialGoals = await _databaseService.getFinancialGoals();
      
      // If no goals exist, load mock data
      if (_financialGoals.isEmpty) {
        await _loadMockGoals();
      }
    } catch (e) {
      _errorMessage = 'Failed to load financial goals: $e';
      print(_errorMessage);
      // If loading fails, try to use mock data
      await _loadMockGoals();
    }
  }
  
  // Generate insights from transactions
  Future<void> _generateInsights() async {
    if (_transactions.isEmpty) {
      _insights = {
        'total_spend': 0.0,
        'total_income': 0.0,
        'net_cashflow': 0.0,
        'spending_by_category': {},
        'income_by_category': {},
        'top_spending_category': null,
        'month_to_month_change': 0.0,
      };
      _forecast = {};
      return;
    }
    
    _insights = _analyticsService.generateSpendingInsights(_transactions);
    _forecast = _analyticsService.generateMonthlyForecast(_transactions);
  }
  
  // Generate AI recommendations
  Future<void> _generateRecommendations() async {
    if (_userProfile == null || _transactions.isEmpty) {
      _recommendations = [];
      return;
    }
    
    try {
      _recommendations = _analyticsService.generateRecommendations(
        _transactions, 
        _userProfile!
      );
      
      // Save recommendations to database
      for (var recommendation in _recommendations) {
        await _databaseService.insertRecommendation(recommendation);
      }
    } catch (e) {
      _errorMessage = 'Failed to generate recommendations: $e';
      print(_errorMessage);
      // Try to load existing recommendations
      _recommendations = await _databaseService.getRecommendations();
    }
  }
  
  // Load mock transactions data
  Future<void> _loadMockTransactions() async {
    try {
      // Load mock data from asset
      String jsonString = await rootBundle.loadString('assets/mock_data/mock_transactions.json');
      List<dynamic> jsonData = json.decode(jsonString);
      
      List<app_models.Transaction> mockTransactions = jsonData.map((json) => app_models.Transaction.fromJson(json)).toList();
      
      // Save to database and update local list
      for (var transaction in mockTransactions) {
        await _databaseService.insertTransaction(transaction);
      }
      
      _transactions = mockTransactions;
    } catch (e) {
      print('Failed to load mock transactions: $e');
    }
  }
  
  // Load mock goals data
  Future<void> _loadMockGoals() async {
    try {
      // Load mock data from asset
      String jsonString = await rootBundle.loadString('assets/mock_data/mock_goals.json');
      List<dynamic> jsonData = json.decode(jsonString);
      
      List<FinancialGoal> mockGoals = jsonData.map((json) => FinancialGoal.fromJson(json)).toList();
      
      // Save to database and update local list
      for (var goal in mockGoals) {
        await _databaseService.insertFinancialGoal(goal);
      }
      
      _financialGoals = mockGoals;
    } catch (e) {
      print('Failed to load mock goals: $e');
    }
  }
  
  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 