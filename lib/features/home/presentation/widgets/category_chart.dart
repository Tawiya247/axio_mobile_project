import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryAmounts;

  const CategoryChart({super.key, required this.categoryAmounts});

  @override
  Widget build(BuildContext context) {
    if (categoryAmounts.isEmpty) {
      return const Center(child: Text('Aucune donnée à afficher'));
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int colorIndex = 0;
    final total = categoryAmounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    categoryAmounts.forEach((category, amount) {
      final percentage = (amount / total * 100).toStringAsFixed(1);

      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '$percentage%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition par catégorie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildLegend(categoryAmounts, colors),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLegend(
    Map<String, double> categoryAmounts,
    List<Color> colors,
  ) {
    final List<Widget> legendItems = [];
    int colorIndex = 0;

    categoryAmounts.forEach((category, amount) {
      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: colors[colorIndex % colors.length],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${category[0].toUpperCase()}${category.substring(1).toLowerCase()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
      colorIndex++;
    });

    return legendItems;
  }
}
