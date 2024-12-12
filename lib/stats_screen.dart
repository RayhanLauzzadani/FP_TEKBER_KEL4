import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  double? exchangeRateIDRtoUSD;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception("API URL is not set in .env");
      }

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRateIDRtoUSD = data['conversion_rates']['IDR'] ?? 1.0;
        });
      } else {
        throw Exception("Failed to fetch exchange rate");
      }
    } catch (e) {
      debugPrint("Error fetching exchange rate: $e");
    }
  }

  Map<String, double> _generateDataMap(QuerySnapshot snapshot) {
    Map<String, double> dataMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] ?? 'Unknown';
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final String currency = data['currency'] ?? 'USD';
      final double convertedAmount = (data['convertedAmount'] as num?)?.toDouble() ?? 0.0;

      // Gunakan convertedAmount jika tersedia, jika tidak lakukan konversi
      final double amountInUSD = convertedAmount > 0
          ? convertedAmount
          : (currency == 'IDR' && exchangeRateIDRtoUSD != null)
              ? amount / exchangeRateIDRtoUSD!
              : amount;

      if (category != 'Add Balance') {
        if (dataMap.containsKey(category)) {
          dataMap[category] = dataMap[category]! + amountInUSD;
        } else {
          dataMap[category] = amountInUSD;
        }
      }
    }

    return dataMap;
  }

  double _calculateTotalAmount(Map<String, double> dataMap) {
    return dataMap.values.fold(0, (sum, item) => sum + item);
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text(
          "No user logged in.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    final colorList = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4484B7), Color(0xFFFFFFFF)],
          stops: [0.54, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Expenses Statistics",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('transactions')
                .where('category', isNotEqualTo: 'Add Balance')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No Data Available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              if (exchangeRateIDRtoUSD == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final dataMap = _generateDataMap(snapshot.data!);
              final totalAmount = _calculateTotalAmount(dataMap);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
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
                          const Text(
                            "Total Expenses",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(totalAmount),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: dataMap.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        height: 24,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
