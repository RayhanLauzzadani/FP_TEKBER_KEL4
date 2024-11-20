import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class StatsScreen extends StatelessWidget {
  final List<Map<String, String>> transactions;

  StatsScreen({required this.transactions});

  Map<String, double> _generateDataMap() {
    Map<String, double> dataMap = {};

    for (var transaction in transactions) {
      final category = transaction['category']!;
      final amount = double.tryParse(transaction['amount']!) ?? 0;

      if (dataMap.containsKey(category)) {
        dataMap[category] = dataMap[category]! + amount;
      } else {
        dataMap[category] = amount;
      }
    }

    return dataMap;
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = _generateDataMap();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: Center(
        child: dataMap.isEmpty
            ? const Text('No data to display')
            : SizedBox(
                width: 300,
                height: 300,
                child: PieChart(
                  dataMap: dataMap,
                  chartType: ChartType.ring,
                  chartRadius: 150,
                  legendOptions: const LegendOptions(
                    showLegends: true,
                    legendPosition: LegendPosition.right,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                  ),
                ),
              ),
      ),
    );
  }
}
