import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatelessWidget {
  final List<Map<String, String>> transactions;

  StatsScreen({required this.transactions});

  // Fungsi untuk menghitung total pengeluaran
  double _calculateTotalExpense(Map<String, double> dataMap) {
    return dataMap.values.fold(0, (sum, item) => sum + item);
  }

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
    final dataMap = _generateDataMap();
    final totalExpense = _calculateTotalExpense(dataMap);
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final colorList = <Color>[
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Scaffold(
      backgroundColor: Colors.blue.shade200,
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut chart dengan total pengeluaran dan label di tengah
                dataMap.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text(
                            'No Transactions Available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            dataMap: dataMap,
                            chartType: ChartType.ring,
                            chartRadius: MediaQuery.of(context).size.width * 0.6,
                            colorList: colorList,
                            legendOptions: const LegendOptions(
                              showLegends: false,
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValues: false,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Total Expenses",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue[300],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currencyFormatter.format(totalExpense),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue[300],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                // Income Breakdown List
                Expanded(
                  child: ListView.separated(
                    itemCount: dataMap.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey, // Warna garis pemisah
                      thickness: 1,       // Ketebalan garis pemisah
                      height: 24,         // Jarak antara item dengan garis
                    ),
                    itemBuilder: (context, index) {
                      String category = dataMap.keys.elementAt(index);
                      double amount = dataMap[category]!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colorList[index % colorList.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormatter.format(amount),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
