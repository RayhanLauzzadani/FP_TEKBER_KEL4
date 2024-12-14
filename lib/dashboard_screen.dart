import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flag/flag.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import '/transaction_history_screen.dart';
import '/transaction_history_widget.dart';
import 'input_transaction_screen.dart';
import 'conversion_calculator_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final formatter =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  double totalBalance = 0.0; // Untuk menyimpan total balance
  bool _isBalanceVisible = true;
  Map<String, dynamic>? exchangeRates;
  bool isLoadingRates = true;

  final Map<String, String> currencySymbols = {
    "IDR": "Rp", // Rupiah
    "USD": "\$", // Dollar
    "EUR": "€", // Euro
    "JPY": "¥", // Yen
    "GBP": "£", // Pound Sterling
    "AUD": "A\$", // Australian Dollar
    "SGD": "S\$", // Singapore Dollar
  };

  final Map<String, String> countryToCurrency = {
    'Indonesia': 'IDR',
    'United States': 'USD',
    'Japan': 'JPY',
    'United Kingdom': 'GBP',
    'European Union': 'EUR',
    'Australia': 'AUD',
    'Singapore': 'SGD',
  };

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
    fetchTotalBalance();
  }

  Future<void> addTransaction(
      double amount, String category, DateTime date, String notes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('User not logged in');
      return;
    }

    final transactionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions');

    try {
      await transactionsRef.add({
        'amount': amount,
        'category': category,
        'date': date,
        'notes': notes,
      });
      print("Transaction added successfully.");
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  Future<void> fetchTotalBalance() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (mounted) {
        setState(() {
          totalBalance = docSnapshot.exists
              ? (docSnapshot['balance'] as num?)?.toDouble() ?? 0.0
              : 0.0;
        });
      }
    } catch (e) {
      print('Error fetching total balance: $e');
    }
  }

  Future<void> fetchExchangeRates() async {
    try {
      final String? apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API URL not found in .env');
      }

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['conversion_rates'] != null) {
          if (mounted) {
            setState(() {
              exchangeRates = data['conversion_rates'];
              isLoadingRates = false;
            });
          }
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      if (mounted) {
        setState(() {
          isLoadingRates = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4484B7),
              Color(0xFFFFFFFF),
            ],
            stops: [0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser
                        ?.uid) // Dokumen berdasarkan UID pengguna
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Balance not found',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    );
                  }

                  // Ambil saldo dari dokumen
                  final double balance =
                      snapshot.data!['balance']?.toDouble() ?? 0.0;
                  print('My Balance: $balance');
                  totalBalance = balance;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildNavbarWelcome(),
                      const SizedBox(height: 40),
                      _buildBalanceSection(
                          totalBalance), // Update bagian balance
                      const SizedBox(height: 30),
                      _buildFeatureSection(context),
                      const SizedBox(height: 30),
                      _buildExchangeRateSection(),
                      const SizedBox(height: 0),
                      Expanded(child: _buildHistoryTransactionSection(context)),
                    ],
                  );
                },
              )),
        ),
      ),
    );
  }

  Widget _buildNavbarWelcome() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Text(
        "Welcome, Guest",
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text(
            "Welcome, User",
            style: TextStyle(fontSize: 16, color: Colors.white),
          );
        }

        // Ambil data nama pengguna
        final String username = snapshot.data!['username'] ?? 'User';

        return Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.userCircle(),
                  size: 40.0,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    Text(
                      username, // Nama dinamis dari Firestore
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection(double totalBalance) {
  return Transform.translate(
    offset: const Offset(0, -30), // Geser bagian My Balance ke atas
    child: Column(
      children: [
        const Text(
          "My Balance",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200), // Batas lebar maksimal
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _isBalanceVisible ? formatter.format(totalBalance) : '******',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Pusatkan teks jika lebih pendek
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible; // Toggle visibility
                });
              },
              child: Icon(
                _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildFeatureSection(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40), // Geser tombol ke atas
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.edit,
            label: "Transaction",
            color: const Color(0xFFA8CAE0),
            onTap: () {
              if (exchangeRates != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputTransactionScreen(
                      onTransactionAdded: () {
                        fetchTotalBalance(); // Memperbarui saldo total di dashboard
                      },
                      exchangeRates: exchangeRates ?? {},
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exchange rates are not loaded yet."),
                  ),
                );
              }
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.add,
            label: "Add Balance",
            color: const Color(0xFFA8CAE0),
            onTap: () => _showAddBalancePopup(context),
          ),
          _buildFeatureCard(
            context,
            icon: Icons.calculate,
            label: "Calculator",
            color: const Color(0xFFA8CAE0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversionCalculatorScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBalancePopup(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    String? selectedCountry;
    String currencySymbol = "\$";

    final Map<String, String> countryToFlagCode = {
      'Indonesia': 'ID',
      'United States': 'US',
      'Japan': 'JP',
      'United Kingdom': 'GB',
      'European Union': 'EU',
      'Australia': 'AU',
      'Singapore': 'SG',
    };

    void _updateCurrencySymbol(String? country, StateSetter setState) {
      setState(() {
        if (country != null) {
          final String? currencyCode = countryToCurrency[country];
          currencySymbol = currencySymbols[currencyCode] ?? "\$";
        } else {
          currencySymbol = "\$";
        }
      });
    }

    Future<void> _pickDate(StateSetter setState) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        });
      }
    }

    void _showCountrySelectionDialog(
        BuildContext context, StateSetter setState) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Select Country'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countryToCurrency.keys.length,
                itemBuilder: (context, index) {
                  final country = countryToCurrency.keys.elementAt(index);
                  final flagCode = countryToFlagCode[country] ?? 'US';
                  return ListTile(
                    leading: ClipOval(
                      child: Flag.fromString(
                        flagCode,
                        height: 32,
                        width: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(country),
                    onTap: () {
                      setState(() {
                        selectedCountry = country;
                        _updateCurrencySymbol(country, setState);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF76A5CA),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Balance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select Country",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          _showCountrySelectionDialog(context, setState),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            if (selectedCountry != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipOval(
                                  child: Flag.fromString(
                                    countryToFlagCode[selectedCountry!]!,
                                    height: 24,
                                    width: 24,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Text(
                              selectedCountry ?? 'Select Country',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickDate(setState),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dateController.text,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Amount",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(currencySymbol,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter amount',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validasi input
                    if (amountController.text.isEmpty ||
                        selectedCountry == null ||
                        dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please complete all fields")),
                      );
                      return;
                    }

                    // Konversi input amount menjadi double
                    final double? amount =
                        double.tryParse(amountController.text);

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter a valid amount")),
                      );
                      return;
                    }

                    try {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        print('Error: User is not logged in');
                        return;
                      }

                      // Ambil currency code berdasarkan negara
                      final String? currencyCode =
                          countryToCurrency[selectedCountry!];
                      if (currencyCode == null) {
                        print(
                            'Error: Currency code not found for country $selectedCountry');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Failed to get currency code for the selected country")),
                        );
                        return;
                      }

                      // Ambil kurs konversi
                      final double conversionRate =
                          (exchangeRates?[currencyCode]?.toDouble() ?? 1.0);

                      // Konversi amount ke USD
                      final double convertedAmount = (amount / conversionRate);

                      // Debugging: Log nilai konversi
                      print('Original Amount: $amount $currencyCode');
                      print('Converted Amount (USD): $convertedAmount');

                      // Update balance di Firestore
                      final docRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid);
                      await FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        final snapshot = await transaction.get(docRef);
                        if (snapshot.exists) {
                          final double currentBalance =
                              (snapshot['balance'] as num?)?.toDouble() ?? 0.0;
                          transaction.update(docRef, {
                            'balance': currentBalance + convertedAmount,
                          });
                        } else {
                          transaction.set(docRef, {'balance': convertedAmount});
                        }
                      });

                      // Tambahkan transaksi ke subkoleksi `transactions`
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('transactions')
                          .add({
                        'amount': convertedAmount, // Jumlah dalam USD
                        'originalAmount':
                            amount, // Jumlah asli sebelum dikonversi
                        'originalCurrency': currencyCode, // Mata uang asli
                        'conversionRate': conversionRate, // Kurs konversi
                        'category': 'Add Balance',
                        'date': Timestamp.fromDate(
                          DateFormat('yyyy-MM-dd').parse(dateController.text),
                        ),
                        'notes': 'Added via Add Balance',
                        'currency': 'USD',
                        'country': selectedCountry,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // Debugging: Log transaksi berhasil
                      print('Transaction successfully added to Firestore.');

                      // Tutup dialog dan tampilkan notifikasi
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Balance added successfully")),
                      );

                      // Refresh saldo total
                      fetchTotalBalance();
                    } catch (e) {
                      print('Error while adding balance: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to add balance")),
                      );
                    }
                  },
                  child:
                      const Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap, // Ganti route dengan onTap
  }) {
    return GestureDetector(
      onTap: onTap, // Panggil fungsi saat kartu ditekan
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.55),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 29, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateSection() {
    if (isLoadingRates) {
      // Shimmer effect saat data sedang dimuat
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              "Exchange Rate",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, // Jumlah shimmer card
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 20 : 12,
                    right: index == 6 ? 20 : 0,
                  ),
                  child: _buildShimmerExchangeRateCard(),
                );
              },
            ),
          ),
        ],
      );
    }

    if (exchangeRates == null || exchangeRates!.isEmpty) {
      return const Center(
        child: Text(
          'Failed to load exchange rates',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    // Data negara dengan kode ISO untuk bendera
    final List<Map<String, String>> currencies = [
      {"code": "IDR", "name": "Indonesian Rupiah"},
      {"code": "USD", "name": "United States Dollar"},
      {"code": "EUR", "name": "Euro"},
      {"code": "JPY", "name": "Japanese Yen"},
      {"code": "GBP", "name": "Pound Sterling"},
      {"code": "AUD", "name": "Australian Dollar"},
      {"code": "SGD", "name": "Singapore Dollar"},
    ];

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Exchange Rate",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => debugPrint("View All clicked"),
                  child: const Text(
                    "View All",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currencies.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final rate = exchangeRates![currency["code"]] ?? 0.0;
                final convertedValue = rate != 0.0 ? totalBalance * rate : 0.0;

                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 20 : 12,
                    right: index == currencies.length - 1 ? 20 : 0,
                  ),
                  child: _buildExchangeRateCard(
                    currency["name"]!,
                    currency["code"]!,
                    convertedValue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerExchangeRateCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 15,
              width: 120,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 100,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateCard(
      String currencyName, String currencyCode, double convertedValue) {
    final symbol =
        currencySymbols[currencyCode] ?? ""; // Simbol mata uang default kosong

    // Formatter untuk angka dengan koma sebagai pemisah ribuan
    final NumberFormat formatter = NumberFormat('#,##0.00'); // Format koma

    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFA8CAE0).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon bendera negara
          ClipOval(
            child: Flag.fromString(currencyCode.substring(0, 2),
                height: 32, width: 32, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          // Nama mata uang
          Text(
            currencyName,
            style: const TextStyle(
              fontSize: 17, // Ukuran font lebih besar
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Nilai konversi dengan FittedBox
          FittedBox(
            fit: BoxFit.scaleDown, // Menyesuaikan ukuran teks dengan batas
            child: Text(
              "$symbol ${formatter.format(convertedValue)}", // Format angka dengan koma
              style: const TextStyle(
                fontSize: 18, // Ukuran font dasar
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTransactionSection(BuildContext context) {
    // Hitung tinggi layar yang tersedia
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight -
        40 - // Tinggi Navbar Welcome
        40 - // Tinggi My Balance Section
        30 - // Tinggi Feature Section
        30 - // Tinggi Exchange Rate Section
        MediaQuery.of(context).padding.top - // Tinggi status bar
        MediaQuery.of(context).viewInsets.bottom; // Tinggi keyboard jika muncul

    return Container(
      width: double.infinity,
      height: availableHeight, // Tinggi yang tersedia
      padding:
          const EdgeInsets.symmetric(horizontal: 20), // Padding kiri dan kanan
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // Latar belakang semi-transparan
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30), // Sudut atas kiri melengkung
          topRight: Radius.circular(30), // Sudut atas kanan melengkung
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan padding atas
          Padding(
            padding: const EdgeInsets.only(top: 20), // Padding atas
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History Transaction",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionHistoryScreen(
                          onTransactionDeleted: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Daftar transaksi
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30), // Sudut bawah kiri melengkung
                bottomRight:
                    Radius.circular(30), // Sudut bawah kanan melengkung
              ),
              child: TransactionHistoryWidget(
                limit: 5, // Menampilkan 5 transaksi terbaru
                allowDelete: false, // Tidak ada tombol hapus di dashboard
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTransactionItem(
      String title, String subtitle, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3), // Shadow lembut
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow ke bawah
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1), // Background biru muda
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amount.contains('-')
                    ? Colors.red
                    : Colors.green, // Warna sesuai nilai
              ),
            ),
          ],
        ),
      ),
    );
  }
}
