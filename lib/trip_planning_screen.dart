import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripPlanningScreen extends StatelessWidget {
  const TripPlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TripPlanningPage(),
    );
  }
}

class TripPlanningPage extends StatefulWidget {
  @override
  _TripPlanningPageState createState() => _TripPlanningPageState();
}

class _TripPlanningPageState extends State<TripPlanningPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      debugPrint("Error: User is not logged in!");
    } else {
      debugPrint("Logged in user UID: $uid");
    }
  }

  CollectionReference<Map<String, dynamic>> get tripsCollection {
    if (uid == null) {
      throw Exception('User is not logged in');
    }
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('trips');
  }

  Future<void> _addTrip(String location, String date, String budget) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      debugPrint("User not logged in. Cannot add trip.");
      return;
    }

    try {
      await tripsCollection.add({
        'location': location,
        'date': date,
        'budget': budget,
        'currency': countryToCurrency[location] ?? 'USD',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip added successfully!')),
      );
      debugPrint("Trip added successfully for user UID: $uid");
    } catch (e) {
      debugPrint("Error adding trip: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding trip: $e')),
      );
    }
  }

  final List<Map<String, String>> countriesWithFlags = [
    {"name": "Indonesia", "code": "ID"},
    {"name": "United States", "code": "US"},
    {"name": "Japan", "code": "JP"},
    {"name": "United Kingdom", "code": "GB"},
    {"name": "European Union", "code": "EU"},
    {"name": "Australia", "code": "AU"},
    {"name": "Singapore", "code": "SG"},
  ];

  final Map<String, String> countryToCurrency = {
    'Indonesia': 'IDR',
    'United States': 'USD',
    'Japan': 'JPY',
    'United Kingdom': 'GBP',
    'European Union': 'EUR',
    'Australia': 'AUD',
    'Singapore': 'SGD',
  };

  void _showAddTripDialog({String? tripId, Map<String, dynamic>? tripData}) {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  String selectedCountry = tripData?['location'] ?? '';
  String currencySymbol = '';
  String currencyCode = '';

  // Jika tripData tidak null, isi form dengan data yang ada
  if (tripData != null) {
    dateController.text = tripData['date'] ?? '';
    budgetController.text = tripData['budget']?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
    currencyCode = tripData['currency'] ?? '';
    selectedCountry = tripData['location'] ?? '';
  }

  void _updateCurrency(String country) {
    currencyCode = countryToCurrency[country] ?? '';
    switch (currencyCode) {
      case 'IDR':
        currencySymbol = 'Rp';
        break;
      case 'USD':
        currencySymbol = '\$';
        break;
      case 'JPY':
        currencySymbol = '¥';
        break;
      case 'GBP':
        currencySymbol = '£';
        break;
      case 'EUR':
        currencySymbol = '€';
        break;
      case 'AUD':
        currencySymbol = 'A\$';
        break;
      case 'SGD':
        currencySymbol = 'S\$';
        break;
      default:
        currencySymbol = '';
    }
  }

  if (selectedCountry.isNotEmpty) {
    _updateCurrency(selectedCountry);
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: const Color(0xFFA1C1DB),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        tripId == null ? 'Add Trip Plan' : 'Edit Trip Plan',
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    const Text(
                      'Select Location',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showCountrySelectionDialog((String country) {
                          setDialogState(() {
                            selectedCountry = country;
                            _updateCurrency(country);
                          });
                        });
                      },
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE7F0F8),
                          border: Border.all(color: const Color(0xFF4383B7), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            if (selectedCountry.isNotEmpty)
                              ClipOval(
                                child: Flag.fromString(
                                  countriesWithFlags.firstWhere(
                                      (country) => country['name'] == selectedCountry)['code']!,
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              selectedCountry.isNotEmpty ? selectedCountry : 'Select Country',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setDialogState(() {
                            dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                          });
                        }
                      },
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE7F0F8),
                          border: Border.all(color: const Color(0xFF4383B7), width: 1.5),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dateController.text.isNotEmpty ? dateController.text : 'Select Date',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Total Budget',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFE7F0F8),
                        border: Border.all(color: const Color(0xFF4383B7), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(
                            currencySymbol,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: budgetController,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Budget',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Budget cannot be empty';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4383B7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && selectedCountry.isNotEmpty) {
                    if (tripId == null) {
                      _addTrip(
                        selectedCountry,
                        dateController.text,
                        '${currencySymbol}${budgetController.text}',
                      );
                    } else {
                      tripsCollection.doc(tripId).update({
                        'location': selectedCountry,
                        'date': dateController.text,
                        'budget': '${currencySymbol}${budgetController.text}',
                        'currency': currencyCode,
                      });
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _showCountrySelectionDialog(Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Select Country'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countriesWithFlags.length,
              itemBuilder: (context, index) {
                final country = countriesWithFlags[index];
                return ListTile(
                  leading: ClipOval(
                    child: Flag.fromString(
                      country['code']!,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(country['name']!),
                  onTap: () {
                    onSelected(country['name']!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Trip Planning',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4484B7),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.54, 1.0],
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 50,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showAddTripDialog();
              },
              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
              label: const Text(
                'Add Trip Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: kToolbarHeight + 130 + 30,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: uid != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('trips')
                      .orderBy('createdAt', descending: true)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  debugPrint("Loading data...");
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint("Error while fetching data: ${snapshot.error}");
                  return const Center(
                    child: Text(
                      'Error loading trips.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  debugPrint("No data found in Firestore for user: $uid");
                  return const Center(
                    child: Text(
                      'No trips found.',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  );
                }

                final trips = snapshot.data!.docs;
                debugPrint("Number of trips found: ${trips.length}");

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index].data();
                    final tripId = trips[index].id;

                    debugPrint("Trip $index data: $trip");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          'Location: ${trip['location'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Date: ${trip['date'] ?? 'N/A'}\nTotal Budget: ${trip['budget'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Color(0xFF4484B7)),
                              onPressed: () {
                                _showAddTripDialog(
                                  tripId: tripId,
                                  tripData: trip,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Color(0xFF4484B7)),
                              onPressed: () {
                                tripsCollection.doc(tripId).delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
