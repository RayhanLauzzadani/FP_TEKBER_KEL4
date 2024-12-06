import 'package:flutter/material.dart';

class ConversionCalculatorScreen extends StatefulWidget {
  @override
  _ConversionCalculatorScreenState createState() =>
      _ConversionCalculatorScreenState();
}

class _ConversionCalculatorScreenState
    extends State<ConversionCalculatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  double _convertedValue = 0.0;
  String _inputCurrencyFlag = '🇮🇩';
  String _outputCurrencyFlag = '🇫🇷';
  String _inputCurrency = 'IDR';
  String _outputCurrency = 'EUR';

  final Map<String, double> _exchangeRates = {
    'USD': 0.000065,
    'EUR': 0.000061,
    'JPY': 0.0096,
  };

  void _convertCurrency() {
    final double input = double.tryParse(_inputController.text) ?? 0;
    setState(() {
      _convertedValue = input * _exchangeRates[_outputCurrency]!;
    });
  }

  void _onCalculatorButtonPressed(String value) {
    if (value == 'C') {
      _inputController.clear();
    } else if (value == ',') {
      if (!_inputController.text.contains('.')) {
        _inputController.text += '.';
      }
    } else {
      _inputController.text += value;
    }
    _convertCurrency();
  }

  void _swapCurrencies() {
    setState(() {
      // Swap flags and currencies
      final tempFlag = _inputCurrencyFlag;
      final tempCurrency = _inputCurrency;
      _inputCurrencyFlag = _outputCurrencyFlag;
      _inputCurrency = _outputCurrency;
      _outputCurrencyFlag = tempFlag;
      _outputCurrency = tempCurrency;
      _convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          'Conversion Calculator',
          style: TextStyle(
            color: Colors.white, // Warna teks putih
          ),
        ),
        backgroundColor: Colors.blue[300], // Background header biru
        iconTheme: const IconThemeData(
          color: Colors.white, // Warna tombol back putih
        ),
      ),
      body: Column(
        children: [
          // Currency Conversion Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    // Input Section
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[300]!),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _inputCurrencyFlag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _inputCurrency,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Rp 0",
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => _convertCurrency(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Output Section
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[100],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _outputCurrencyFlag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _outputCurrency,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            '${_outputCurrencyFlag} ${_convertedValue.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Swap Button
                Positioned(
                  top: 52, // Positioned between the two boxes
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue[300],
                    child: InkWell(
                      onTap: _swapCurrencies,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // Calculator Keypad
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 tombol per baris
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2, // Slightly taller buttons
                ),
                itemCount: 12, // Total tombol (7-9, 4-6, 1-3, C, 0, ,)
                itemBuilder: (context, index) {
                  final buttons = [
                    '7',
                    '8',
                    '9',
                    '4',
                    '5',
                    '6',
                    '1',
                    '2',
                    '3',
                    'C',
                    '0',
                    ','
                  ];
                  final button = buttons[index];

                  return ElevatedButton(
                    onPressed: () {
                      _onCalculatorButtonPressed(button);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue[300], // Background tombol biru
                    ),
                    child: Text(
                      button,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Teks tombol putih
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
