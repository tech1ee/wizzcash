import 'package:intl/intl.dart';

class Formatters {
  // Currency formatter
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }
  
  // Date formatters
  static final DateFormat _shortDateFormatter = DateFormat('MM/dd/yyyy');
  static final DateFormat _mediumDateFormatter = DateFormat('MMM d, yyyy');
  static final DateFormat _longDateFormatter = DateFormat('MMMM d, yyyy');
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');
  
  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }
  
  static String formatMediumDate(DateTime date) {
    return _mediumDateFormatter.format(date);
  }
  
  static String formatLongDate(DateTime date) {
    return _longDateFormatter.format(date);
  }
  
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }
  
  // Percent formatter
  static String formatPercent(double value, {int decimalPlaces = 1}) {
    NumberFormat percentFormatter = NumberFormat.percentPattern();
    percentFormatter.maximumFractionDigits = decimalPlaces;
    return percentFormatter.format(value / 100);
  }
  
  // Format transaction amount with consistent sign indicator
  static String formatTransactionAmount(double amount, String type) {
    // Always use absolute value of amount to avoid double negative signs
    double absAmount = amount.abs();
    String formattedAmount = _currencyFormatter.format(absAmount);
    
    // Add the appropriate sign prefix based on transaction type
    if (type == 'credit') {
      return '+$formattedAmount';
    } else {
      return '-$formattedAmount';
    }
  }
  
  // Format a double with specified decimal places
  static String formatDouble(double value, {int decimalPlaces = 2}) {
    NumberFormat formatter = NumberFormat('0.${'0' * decimalPlaces}');
    return formatter.format(value);
  }
  
  // Format a number with comma separators
  static String formatNumber(int number) {
    NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  
  // Format the time remaining until a goal date
  static String formatTimeRemaining(DateTime targetDate) {
    final now = DateTime.now();
    
    if (targetDate.isBefore(now)) {
      return 'Past due';
    }
    
    final difference = targetDate.difference(now);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();
      return '$years year${years != 1 ? 's' : ''} ${months > 0 ? ', $months month${months != 1 ? 's' : ''}' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      final days = difference.inDays % 30;
      return '$months month${months != 1 ? 's' : ''} ${days > 0 ? ', $days day${days != 1 ? 's' : ''}' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''}';
    } else {
      return 'Less than an hour';
    }
  }
  
  // Formats a priority string to a more readable form
  static String formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return priority;
    }
  }
} 