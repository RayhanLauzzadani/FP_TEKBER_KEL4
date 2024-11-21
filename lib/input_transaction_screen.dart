import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputTransactionScreen extends StatefulWidget {
  final void Function(Map<String, String>) onSaveTransaction;

  InputTransactionScreen({required this.onSaveTransaction});

  @override
  _InputTransactionScreenState createState() => _InputTransactionScreenState();
}

class _InputTransactionScreenState extends State<InputTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedCountry;
  String _selectedCurrencySymbol = '';
  String? _selectedCategory;

  final List<Map<String, String>> countryCurrencyList = [
    {'country': 'United States', 'currency': 'USD', 'symbol': '\$'},
    {'country': 'Indonesia', 'currency': 'IDR', 'symbol': 'Rp'},
    {'country': 'Japan', 'currency': 'JPY', 'symbol': '¥'},
    {'country': 'United Kingdom', 'currency': 'GBP', 'symbol': '£'},
    {'country': 'European Union', 'currency': 'EUR', 'symbol': '€'},
  ];

  final List<Map<String, dynamic>> categoryList = [
    {'category': 'Akomodasi', 'icon': Icons.hotel},
    {'category': 'Food', 'icon': Icons.fastfood},
    {'category': 'Transport', 'icon': Icons.directions_car},
    {'category': 'Shopping', 'icon': Icons.shopping_bag},
  ];

  String get formattedDate {
    return _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : 'Select Date';
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedCountry != null &&
        _selectedCategory != null) {
      final transaction = {
        'country': _selectedCountry!,
        'category': _selectedCategory!,
        'amount': _amountController.text,
        'date': formattedDate,
        'currency': _selectedCurrencySymbol,
      };
      widget.onSaveTransaction(transaction);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before saving'),
        ),
      );
    }
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

  void _onCountrySelected(String? country) {
    setState(() {
      _selectedCountry = country;
      _selectedCurrencySymbol = countryCurrencyList
              .firstWhere((element) => element['country'] == country)['symbol'] ?? 
          '';
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade200, // Latar belakang biru muda
      appBar: AppBar(
        title: const Text('Input Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Icon back putih
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Warna latar form tetap putih
            borderRadius: BorderRadius.circular(16), // Sudut membulat
            border: Border.all(
              color: Colors.blue[300]!, // Warna border biru 300
              width: 2, // Lebar border
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Country Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    hint: const Text('Select Country'),
                    decoration: InputDecoration(
                      labelText: 'Country',
                      labelStyle: TextStyle(color: Colors.blue[300]), // Warna label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                      ),
                    ),
                    items: countryCurrencyList.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['country'],
                        child: Text(item['country']!),
                      );
                    }).toList(),
                    onChanged: _onCountrySelected,
                    validator: (value) =>
                        value == null ? 'Please select a country' : null,
                  ),
                  const SizedBox(height: 20),
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.blue[300]), // Warna label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                      ),
                    ),
                    items: categoryList.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['category'],
                        child: Row(
                          children: [
                            Icon(item['icon'], color: Colors.blue[300]),
                            const SizedBox(width: 10),
                            Text(item['category']!),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _onCategorySelected,
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 20),
                  // Amount with Currency Symbol
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.blue[300]), // Warna label
                      prefixText: _selectedCurrencySymbol,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                      ),
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
                  const SizedBox(height: 20),
                  // Date Picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: TextStyle(color: Colors.blue[300]), // Warna label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[300]), // Icon kalender biru
                      ),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blue[300], // Warna button biru
                      foregroundColor: Colors.white, // Warna teks putih
                    ),
                    child: const Text('Save Transaction'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
