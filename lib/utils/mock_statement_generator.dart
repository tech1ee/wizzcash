import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Utility to generate mock bank statements for testing the import feature
class MockStatementGenerator {
  static final DateFormat _dateFormatter = DateFormat('MM/dd/yyyy');
  static final Random _random = Random();
  
  /// Generate a mock bank statement PDF file
  static Future<File> generateMockBankStatement() async {
    final pdf = pw.Document();
    
    // Generate account info
    final accountNumber = 'XXXX-XXXX-${_random.nextInt(9000) + 1000}';
    final statementPeriod = 'May 01, 2023 - May 31, 2023';
    final accountHolder = 'John Doe';
    
    // Generate mock transactions
    final transactions = _generateMockTransactions();
    
    // Calculate totals
    double totalDeposits = 0;
    double totalWithdrawals = 0;
    
    for (final transaction in transactions) {
      if (transaction['type'] == 'credit') {
        totalDeposits += transaction['amount'] as double;
      } else {
        totalWithdrawals += transaction['amount'] as double;
      }
    }
    
    // Calculate balance
    final openingBalance = 2500.0;
    final closingBalance = openingBalance + totalDeposits - totalWithdrawals;
    
    // Create a simple text-based bank logo
    final bankLogo = pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: 'WIZZ',
            style: pw.TextStyle(
              color: PdfColors.green700,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TextSpan(
            text: 'BANK',
            style: pw.TextStyle(
              color: PdfColors.blue700,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    
    // Build PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  bankLogo,
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('BANK STATEMENT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.SizedBox(height: 4),
                      pw.Text(statementPeriod, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Account Holder', style: const pw.TextStyle(color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text(accountHolder, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Account Number', style: const pw.TextStyle(color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text(accountNumber, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Opening Balance', style: const pw.TextStyle(color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text('\$${openingBalance.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Closing Balance', style: const pw.TextStyle(color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text('\$${closingBalance.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Text('Transaction History', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3), // Date
                1: const pw.FlexColumnWidth(6), // Description
                2: const pw.FlexColumnWidth(3), // Amount
              },
              children: [
                // Table header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Transaction rows
                ...transactions.map((transaction) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(transaction['date'] as String),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(transaction['description'] as String),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          transaction['type'] == 'credit'
                              ? '+\$${(transaction['amount'] as double).toStringAsFixed(2)}'
                              : '-\$${(transaction['amount'] as double).toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            color: transaction['type'] == 'credit' ? PdfColors.green700 : PdfColors.red700,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Deposits:'),
                    pw.Text('Total Withdrawals:'),
                    pw.SizedBox(height: 4),
                    pw.Text('Net Change:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('+\$${totalDeposits.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.green700)),
                    pw.Text('-\$${totalWithdrawals.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.red700)),
                    pw.SizedBox(height: 4),
                    pw.Text('\$${(totalDeposits - totalWithdrawals).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Text('This is a computer-generated statement and does not require a signature',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('For any inquiries, please contact customer service at 1-800-123-4567',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.SizedBox(height: 5),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );
    
    // Save the PDF to a temporary file
    final output = await _getTempFile();
    await output.writeAsBytes(await pdf.save());
    
    return output;
  }
  
  // Get a temporary file path
  static Future<File> _getTempFile() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return File('${directory.path}/mockStatement_$timestamp.pdf');
  }
  
  // Generate mock transactions data
  static List<Map<String, dynamic>> _generateMockTransactions() {
    final List<Map<String, dynamic>> transactions = [];
    
    // Base date for mock transactions (May 2023)
    final baseDate = DateTime(2023, 5, 1);
    
    // Sample merchants and descriptions
    final merchants = [
      {'name': 'Walmart', 'category': 'Shopping'},
      {'name': 'Amazon', 'category': 'Shopping'},
      {'name': 'Netflix', 'category': 'Entertainment'},
      {'name': 'Spotify', 'category': 'Entertainment'},
      {'name': 'Uber', 'category': 'Transportation'},
      {'name': 'Shell Gas Station', 'category': 'Transportation'},
      {'name': 'Whole Foods', 'category': 'Food'},
      {'name': 'Starbucks', 'category': 'Food'},
      {'name': 'AT&T', 'category': 'Utilities'},
      {'name': 'State Farm Insurance', 'category': 'Insurance'},
      {'name': 'CVS Pharmacy', 'category': 'Health'},
      {'name': 'LA Fitness', 'category': 'Health'},
      {'name': 'Home Depot', 'category': 'Housing'},
      {'name': 'Rent Payment', 'category': 'Housing'},
      {'name': 'Apple Store', 'category': 'Electronics'},
      {'name': 'Best Buy', 'category': 'Electronics'},
    ];
    
    // Generate 20-30 transactions
    final numTransactions = _random.nextInt(11) + 20;
    
    for (int i = 0; i < numTransactions; i++) {
      // Random date within May 2023
      final transactionDate = baseDate.add(Duration(days: _random.nextInt(31)));
      
      // Randomly select a merchant
      final merchant = merchants[_random.nextInt(merchants.length)];
      
      // Determine if it's a deposit or withdrawal (mostly withdrawals)
      final isDeposit = _random.nextDouble() < 0.2;
      
      String description;
      double amount;
      
      if (isDeposit) {
        description = 'Direct Deposit - Salary';
        amount = (_random.nextInt(200) * 10) + 1000.0;
      } else {
        description = 'Purchase at ${merchant['name']}';
        amount = (_random.nextInt(100) + 1) + (_random.nextInt(100) / 100);
      }
      
      // Add the transaction
      transactions.add({
        'date': _dateFormatter.format(transactionDate),
        'description': description,
        'amount': amount,
        'type': isDeposit ? 'credit' : 'debit',
        'category': isDeposit ? 'Income' : merchant['category'],
      });
    }
    
    // Sort transactions by date
    transactions.sort((a, b) {
      final dateA = _dateFormatter.parse(a['date'] as String);
      final dateB = _dateFormatter.parse(b['date'] as String);
      return dateA.compareTo(dateB);
    });
    
    return transactions;
  }
} 