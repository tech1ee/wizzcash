import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/financial_data_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinancialDataProvider()),
      ],
      child: MaterialApp(
        title: 'WizzCash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
