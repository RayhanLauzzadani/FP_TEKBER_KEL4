import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class StatsScreen extends StatelessWidget {
  final List<Map<String, String>> transactions;

  StatsScreen({required this.transactions});

  // Fungsi untuk menghasilkan data grafik dari transaksi
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
    // Mendapatkan data grafik
    final dataMap = _generateDataMap();

    // Palet warna untuk kategori
    final colorList = <Color>[
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    // Mendapatkan ukuran layar
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue.shade200, // Warna latar belakang
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Expenses Statistics",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Radius sudut
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header teks
                const Text(
                  'Here is your transaction report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20), // Jarak
                // Grafik
                dataMap.isEmpty
                    ? const Text(
                        'No Transactions Available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    : PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.ring,
                        chartRadius: deviceWidth * 0.6, // 60% dari lebar layar
                        colorList: colorList,
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false, // Legenda vertikal
                          legendPosition: LegendPosition.bottom,
                          legendTextStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          chartValueStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
