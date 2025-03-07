import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class SpendingChart extends StatelessWidget {
  final Map<String, double> spendingByCategory;
  final double totalSpending;
  
  const SpendingChart({
    Key? key,
    required this.spendingByCategory,
    required this.totalSpending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spendingByCategory.isEmpty || totalSpending == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No spending data available'),
        ),
      );
    }
    
    // Sort categories by amount (descending)
    final sortedCategories = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Fixed colors for pie chart sections
    final List<Color> sectionColors = [
      const Color(0xFF7AFFD0), // primary color
      const Color(0xFFE4FD5B), // accent color
      const Color(0xFF6C757D), // secondary text color
      const Color(0xFF28A745), // success color
      const Color(0xFFFFC107), // warning color
      const Color(0xFFDC3545), // error color
      const Color(0xFF17A2B8), // info color
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    // Create pie chart sections
    int colorIndex = 0;
    final List<PieChartSectionData> sections = sortedCategories.map((entry) {
      final percentage = (entry.value / totalSpending) * 100;
      final color = sectionColors[colorIndex % sectionColors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
            sortedCategories.length,
            (index) {
              final entry = sortedCategories[index];
              final color = sectionColors[index % sectionColors.length];
              final percentage = (entry.value / totalSpending) * 100;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                      style: AppTheme.captionStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Total spending
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Total Spending: ${Formatters.formatCurrency(totalSpending)}',
            style: AppTheme.subheadingStyle,
          ),
        ),
      ],
    );
  }
} 