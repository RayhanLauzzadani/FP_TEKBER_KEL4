import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InputTransactionScreen extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  final Map<String, dynamic> exchangeRates; // Menambahkan parameter kurs mata uang

const InputTransactionScreen({
  super.key,
  required this.onTransactionAdded,
  required this.exchangeRates, // Parameter baru untuk kurs
});
  
  

  @override
  _InputTransactionScreenState createState() => _InputTransactionScreenState();
}

final Map<String, String> countryToCurrencyCode = {
  'Indonesia': 'IDR',
  'United States': 'USD',
  'Japan': 'JPY',
  'United Kingdom': 'GBP',
  'European Union': 'EUR',
  'Australia': 'AUD',
  'Singapore': 'SGD',
};

class _InputTransactionScreenState extends State<InputTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  String? selectedCountry;
  String? selectedCategory;
  String? notes;
  String currencySymbol = '';

  final List<String> countries = [
    'Indonesia',
    'United States',
    'Japan',
    'United Kingdom',
    'European Union',
    'Australia',
    'Singapore',
  ];
  
  final List<Map<String, String>> countriesWithFlags = [
    {"name": "Indonesia", "code": "ID"},
    {"name": "United States", "code": "US"},
    {"name": "Japan", "code": "JP"},
    {"name": "United Kingdom", "code": "GB"},
    {"name": "European Union", "code": "EU"},
    {"name": "Australia", "code": "AU"},
    {"name": "Singapore", "code": "SG"},
  ];


  final List<String> categories = [
    'Food',
    'Shopping',
    'Transportation',
    'Accommodation',
  ];

  final List<Map<String, dynamic>> categoriesWithIcons = [
  {
    "name": "Transport",
    "icon": Icon(
      PhosphorIcons.car(),
      size: 26.0,
      color: Colors.white,
    ),
  },
  {
    "name": "Food",
    "icon": Icon(
      PhosphorIcons.hamburger(),
      size: 26.0,
      color: Colors.white,
    ),
  },
  {
    "name": "Shopping",
    "icon": Icon(
      PhosphorIcons.shoppingBag(),
      size: 26.0,
      color: Colors.white,
    ),
  },
  {
    "name": "Akomodasi",
    "icon": Icon(
      PhosphorIcons.bed(),
      size: 26.0,
      color: Colors.white,
    ),
  },
];

  

  void _updateCurrencySymbol(String? country) {
    switch (country) {
      case 'Indonesia':
        currencySymbol = 'Rp.';
        break;
      case 'United States':
        currencySymbol = '\$';
        break;
      case 'Japan':
        currencySymbol = '¥';
        break;
      case 'United Kingdom':
        currencySymbol = '£';
        break;
      case 'European Union':
        currencySymbol = '€';
        break;
      case 'Singapore': // Tambahkan Singapore
        currencySymbol = 'S\$';
        break;
      case 'Australia': // Tambahkan Australia
        currencySymbol = 'A\$';
        break;
      default:
        currencySymbol = '';
    }
  }

  double _convertToUSD(double amount, String? country) {
  String currencyCode;
  switch (country) {
    case 'Indonesia':
      currencyCode = 'IDR';
      break;
    case 'United States':
      currencyCode = 'USD';
      break;
    case 'Japan':
      currencyCode = 'JPY';
      break;
    case 'United Kingdom':
      currencyCode = 'GBP';
      break;
    case 'European Union':
      currencyCode = 'EUR';
      break;
    default:
      currencyCode = 'USD'; // Default ke USD
  }

  // Ambil kurs dari exchangeRates
  double conversionRate = widget.exchangeRates[currencyCode] ?? 1.0;
  return amount / conversionRate;
}

  Future<void> _showModalDialog(
    String title, List<String> options, Function(String) onSelected) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF4383B7),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final country = countriesWithFlags[index];
              return ListTile(
                leading: ClipOval(
                  child: Flag.fromString(
                    country['code']!,
                    height: 24, // Tinggi flag
                    width: 24,  // Lebar flag
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(country['name']!, style: const TextStyle(fontSize: 16)),
                onTap: () {
                  onSelected(country['name']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
        ],
      );
    },
  );
}


  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
  if (_formKey.currentState!.validate() &&
      _selectedDate != null &&
      selectedCountry != null &&
      selectedCategory != null) {
    try {
      // Ambil UID pengguna yang login
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User is not logged in.");
      }

      // Ambil nilai dari input amount
      final double inputAmount = double.parse(_amountController.text);

      // Ambil kode mata uang berdasarkan negara yang dipilih
      final String? currencyCode = countryToCurrencyCode[selectedCountry];
      if (currencyCode == null) {
        throw Exception("Currency code for $selectedCountry not found.");
      }

      // Cari nilai tukar menggunakan currencyCode
      final double? conversionRate = widget.exchangeRates[currencyCode]?.toDouble();
      if (conversionRate == null) {
        throw Exception("Currency conversion rate for $currencyCode not found.");
      }

      // Konversi nilai ke USD
      final double convertedAmount = inputAmount / conversionRate;

      // Ambil referensi dokumen pengguna berdasarkan UID
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Dapatkan saldo pengguna
      final DocumentSnapshot userDocSnapshot = await userDocRef.get();
      if (!userDocSnapshot.exists) {
        throw Exception("User document not found in Firestore.");
      }

      final double currentBalance =
          (userDocSnapshot['balance'] as num).toDouble(); // Pastikan ke double

      // Pastikan saldo cukup
      if (currentBalance < convertedAmount) {
        throw Exception("Insufficient balance to save this transaction.");
      }

      // Simpan transaksi ke subkoleksi `transactions` milik pengguna
      await userDocRef.collection('transactions').add({
        'country': selectedCountry!,
        'category': selectedCategory!,
        'amount': inputAmount,
        'convertedAmount': convertedAmount,
        'createdAt': Timestamp.fromDate(_selectedDate!), // Gunakan 'createdAt'
        'currency': currencyCode,
        'notes': notes,
      });

      // Perbarui saldo di dokumen pengguna
      await userDocRef.update({'balance': FieldValue.increment(-convertedAmount)});

      // Panggil callback untuk memperbarui tampilan saldo
      widget.onTransactionAdded();

      // Tampilkan dialog sukses dan kembali ke dashboard
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transaction Successful'),
          content: const Text('Your transaction has been added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke dashboard screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error saving transaction: $e");

      String errorMessage;
      if (e.toString().contains('Currency code')) {
        errorMessage = "Currency code for $selectedCountry not found.";
      } else if (e.toString().contains('conversion rate')) {
        errorMessage = "Currency conversion rate for $selectedCountry not available.";
      } else if (e.toString().contains('User document')) {
        errorMessage = "Unable to fetch user data from Firestore.";
      } else if (e.toString().contains('Insufficient balance')) {
        errorMessage = "Insufficient balance to save this transaction.";
      } else {
        errorMessage = "An unexpected error occurred: $e.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save transaction: $errorMessage')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please complete all fields before saving the transaction.',
        ),
      ),
    );
  }
}

void _showCategoryDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Select Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF4383B7),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categoriesWithIcons.length,
            itemBuilder: (context, index) {
              final category = categoriesWithIcons[index];
              return ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF79A4C0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: category['icon'] as Widget,
                ),
                title: Text(
                  category['name']!,
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = category['name'];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
        ],
      );
    },
  );
}



  @override
Widget build(BuildContext context) {
  const boxHeight = 55.0;
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4484B7), // Gradient dari #4484B7 hingga #FFFFFF
          Color(0xFFFFFFFF),
        ],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Input Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Jarak dari AppBar ke rectangle
            const SizedBox(height: 35),

            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), // Padding dalam rectangle
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country
                      const Text(
                        'Country',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
  onTap: () => _showModalDialog(
    'Select Country',
    countriesWithFlags.map((country) => country['name']!).toList(),
    (value) {
      setState(() {
        selectedCountry = value;
        _updateCurrencySymbol(value);
      });
    },
  ),
  child: Container(
    height: boxHeight,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: const Color(0xFFDDEBF6),
      border: Border.all(
        color: const Color.fromARGB(255, 125, 175, 216), // Border hex #4383B7
        width: 1.5,
      ),
    ),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        if (selectedCountry != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipOval(
              child: Flag.fromString(
                countriesWithFlags
                    .firstWhere((country) => country['name'] == selectedCountry)['code']!,
                height: 24, // Tinggi flag
                width: 24,  // Lebar flag
                fit: BoxFit.cover,
              ),
            ),
          ),
        Text(
          selectedCountry ?? 'Select Country',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  ),
),


                      const SizedBox(height: 16.0),

                      // Category
                      const Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
  onTap: () => _showCategoryDialog(),
  child: Container(
    height: boxHeight,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: const Color(0xFFDDEBF6),
      border: Border.all(
        color: const Color.fromARGB(255, 125, 175, 216), // Border hex #4383B7
        width: 1.5,
      ),
    ),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        if (selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF79A4C0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: categoriesWithIcons
                  .firstWhere((category) => category['name'] == selectedCategory)['icon']
                  as Widget,
            ),
          ),
        Text(
          selectedCategory ?? 'Select Category',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  ),
),


                      const SizedBox(height: 16.0),

                      // Amount
                      const Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: boxHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFDDEBF6),
                          border: Border.all(
                            color: const Color.fromARGB(255, 125, 175, 216), // Border hex #4383B7
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            prefixText: currencySymbol,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Amount must be a number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Date
                      const Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          height: boxHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFDDEBF6),
                            border: Border.all(
                              color: const Color.fromARGB(255, 125, 175, 216), // Border hex #4383B7
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                    : 'Select Date',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today, color: Color(0xFF4383B7)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Add Notes
                      const Text(
                        'Add Notes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFDDEBF6),
                          border: Border.all(
                            color: const Color.fromARGB(255, 125, 175, 216), // Border hex #4383B7
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onChanged: (value) {
                            setState(() {
                              notes = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Save Transaction Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4383B7),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Save Transaction',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
