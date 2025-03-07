import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/transaction.dart' as app_models;
import '../models/financial_goal.dart';
import '../models/recommendation.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'wizzcash.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        target_date TEXT NOT NULL,
        priority TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recommendations(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        potential_savings REAL NOT NULL,
        priority TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        monthly_income REAL NOT NULL,
        budget_limits TEXT NOT NULL,
        has_completed_onboarding INTEGER NOT NULL
      )
    ''');
  }

  // Transaction methods
  Future<int> insertTransaction(app_models.Transaction transaction) async {
    Database db = await database;
    return await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<app_models.Transaction>> getTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return app_models.Transaction.fromJson(maps[i]);
    });
  }

  Future<int> updateTransaction(app_models.Transaction transaction) async {
    Database db = await database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    Database db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Financial Goal methods
  Future<int> insertFinancialGoal(FinancialGoal goal) async {
    Database db = await database;
    return await db.insert(
      'financial_goals',
      goal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FinancialGoal>> getFinancialGoals() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('financial_goals');
    return List.generate(maps.length, (i) {
      return FinancialGoal.fromJson(maps[i]);
    });
  }

  Future<int> updateFinancialGoal(FinancialGoal goal) async {
    Database db = await database;
    return await db.update(
      'financial_goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteFinancialGoal(String id) async {
    Database db = await database;
    return await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Recommendation methods
  Future<int> insertRecommendation(Recommendation recommendation) async {
    Database db = await database;
    return await db.insert(
      'recommendations',
      recommendation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recommendation>> getRecommendations() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recommendations');
    return List.generate(maps.length, (i) {
      return Recommendation.fromJson(maps[i]);
    });
  }

  // User Profile methods
  Future<int> insertUserProfile(UserProfile profile) async {
    Database db = await database;
    Map<String, dynamic> profileMap = profile.toJson();
    // Convert budget_limits Map to a string for storage
    profileMap['budget_limits'] = profile.budgetLimits.toString();
    profileMap['has_completed_onboarding'] = profile.hasCompletedOnboarding ? 1 : 0;
    
    return await db.insert(
      'user_profile',
      profileMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile');
    
    if (maps.isEmpty) {
      return null;
    }
    
    Map<String, dynamic> profileData = Map<String, dynamic>.from(maps.first);
    
    // Convert string representation of budget_limits back to a Map
    String budgetLimitsStr = profileData['budget_limits'];
    Map<String, double> budgetLimits = {};
    
    // Parse the string back to a Map
    if (budgetLimitsStr.startsWith('{') && budgetLimitsStr.endsWith('}')) {
      budgetLimitsStr = budgetLimitsStr.substring(1, budgetLimitsStr.length - 1);
      List<String> pairs = budgetLimitsStr.split(', ');
      for (String pair in pairs) {
        List<String> keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          budgetLimits[keyValue[0]] = double.parse(keyValue[1]);
        }
      }
    }
    
    profileData['budget_limits'] = budgetLimits;
    profileData['has_completed_onboarding'] = profileData['has_completed_onboarding'] == 1;
    
    return UserProfile.fromJson(profileData);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    Database db = await database;
    Map<String, dynamic> profileMap = profile.toJson();
    profileMap['budget_limits'] = profile.budgetLimits.toString();
    profileMap['has_completed_onboarding'] = profile.hasCompletedOnboarding ? 1 : 0;
    
    return await db.update(
      'user_profile',
      profileMap,
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }
} 