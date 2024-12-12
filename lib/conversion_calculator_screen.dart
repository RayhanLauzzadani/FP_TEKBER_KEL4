import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ConversionCalculatorScreen extends StatefulWidget {
  @override
  _ConversionCalculatorScreenState createState() =>
      _ConversionCalculatorScreenState();
}

class _ConversionCalculatorScreenState
    extends State<ConversionCalculatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  double _convertedValue = 0.0;

  // Current selected currencies
  String _inputCurrency = 'IDR';
  String _outputCurrency = 'USD';

  // Exchange rates
  Map<String, double> _exchangeRates = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Mapping of 7 selected currencies to country codes
  final Map<String, String> _flagCodes = {
    'IDR': 'ID',
    'USD': 'US',
    'EUR': 'EU',
    'JPY': 'JP',
    'GBP': 'GB',
    'AUD': 'AU',
    'SGD': 'SG',
  };

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
  final String? apiUrl = dotenv.env['API_URL'];

  if (apiUrl == null) {
    setState(() {
      _errorMessage = 'API URL is not defined in .env file';
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rates = data['conversion_rates'] as Map<String, dynamic>;

      // Filter hanya untuk 7 negara dan pastikan tipe datanya double
      final filteredRates = rates.entries
          .where((entry) => _flagCodes.containsKey(entry.key))
          .map((entry) => MapEntry(entry.key, (entry.value as num).toDouble()))
          .toList();

      setState(() {
        _exchangeRates = Map<String, double>.fromEntries(filteredRates);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load exchange rates. HTTP ${response.statusCode}';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error fetching exchange rates: $e';
      _isLoading = false;
    });
  }
}


  void _convertCurrency() {
    final double input = double.tryParse(_inputController.text) ?? 0;
    setState(() {
      _convertedValue = input *
          (_exchangeRates[_outputCurrency]! / _exchangeRates[_inputCurrency]!);
    });
  }

  void _onCalculatorButtonPressed(String value) {
    if (value == 'C') {
      _inputController.clear();
    } else {
      setState(() {
        _inputController.text += value;
      });
    }
    _convertCurrency();
  }

  void _swapCurrencies() {
    setState(() {
      final tempCurrency = _inputCurrency;
      _inputCurrency = _outputCurrency;
      _outputCurrency = tempCurrency;
      _convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4484B7),
      appBar: AppBar(
        title: const Text(
          'Conversion Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                // Input Currency Section
                                _buildCurrencyInput(
                                  currency: _inputCurrency,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _inputCurrency = newValue!;
                                      _convertCurrency();
                                    });
                                  },
                                  amount: _inputController.text.isEmpty
                                      ? '0.00'
                                      : _inputController.text,
                                ),
                                const SizedBox(height: 12),
                                // Output Currency Section
                                _buildCurrencyInput(
                                  currency: _outputCurrency,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _outputCurrency = newValue!;
                                      _convertCurrency();
                                    });
                                  },
                                  amount: _convertedValue.toStringAsFixed(2),
                                ),
                              ],
                            ),
                            // Swap Button
                            Positioned(
                              top: 55,
                              child: Material(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xFF82A1C6),
                                child: InkWell(
                                  onTap: _swapCurrencies,
                                  child: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Icon(
                                      Icons.swap_vert,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Keypad Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              final buttons = [
                                '1',
                                '2',
                                '3',
                                '4',
                                '5',
                                '6',
                                '7',
                                '8',
                                '9',
                                '000',
                                '0',
                                'C'
                              ];
                              final button = buttons[index];

                              return ElevatedButton(
                                onPressed: () {
                                  _onCalculatorButtonPressed(button);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shadowColor: Colors.grey.withOpacity(0.3),
                                  elevation: 2,
                                ),
                                child: Text(
                                  button,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String currency,
    required ValueChanged<String?> onChanged,
    required String amount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currency,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              items: _exchangeRates.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      ClipOval(
                        child: Flag.fromString(
                          _flagCodes[value] ?? 'US',
                          height: 32,
                          width: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
