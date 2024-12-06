import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TripPlanningScreen extends StatefulWidget {
  @override
  _TripPlanningScreenState createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends State<TripPlanningScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime? _selectedDate;
  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Trip Planning",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue[300],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField("Destination", _destinationController),
                  const SizedBox(height: 10),
                  _buildDatePicker(context),
                  const SizedBox(height: 10),
                  _buildInputField("Budget", _budgetController, isCurrency: true),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildButton(
                      "Save Trip",
                      onPressed: _saveTrip,
                      backgroundColor: Colors.blue[300]!,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Trips List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('trips').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No trips found."));
                  }
                  final trips = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return _buildTripCard(trip);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField(String label, TextEditingController controller,
      {bool isCurrency = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label :",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[300],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              keyboardType:
                  isCurrency ? TextInputType.number : TextInputType.text,
              style: TextStyle(color: Colors.blue[300]),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintStyle: TextStyle(color: Colors.blue[300]!.withOpacity(0.7)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Date Picker Widget
  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "Date :",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[300],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat("dd-MM-yyyy").format(_selectedDate!)
                    : "Select a date",
                style: TextStyle(color: Colors.blue[300]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Button Widget
  Widget _buildButton(String label,
      {required VoidCallback onPressed, required Color backgroundColor}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Trip Card Widget
  Widget _buildTripCard(QueryDocumentSnapshot trip) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          trip['destination'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat("dd-MM-yyyy").format(trip['date'].toDate())),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_currencyFormatter.format(trip['budget'])),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTrip(trip.id),
            ),
          ],
        ),
        onTap: () {
          _showEditTripDialog(trip);
        },
      ),
    );
  }

  // Save Trip to Firebase
  void _saveTrip() async {
    if (_destinationController.text.isEmpty ||
        _selectedDate == null ||
        _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('trips').add({
      'destination': _destinationController.text,
      'date': _selectedDate,
      'budget': double.parse(_budgetController.text),
    });

    _clearForm();
  }

  // Delete Trip from Firebase
  void _deleteTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Trip deleted successfully"),
      ),
    );
  }

  // Show Edit Trip Dialog
  void _showEditTripDialog(QueryDocumentSnapshot trip) {
    _destinationController.text = trip['destination'];
    _selectedDate = trip['date'].toDate();
    _budgetController.text = trip['budget'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Trip"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField("Destination", _destinationController),
              const SizedBox(height: 10),
              _buildDatePicker(context),
              const SizedBox(height: 10),
              _buildInputField("Budget", _budgetController, isCurrency: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('trips')
                    .doc(trip.id)
                    .update({
                  'destination': _destinationController.text,
                  'date': _selectedDate,
                  'budget': double.parse(_budgetController.text),
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Clear Form
  void _clearForm() {
    _destinationController.clear();
    _budgetController.clear();
    _selectedDate = null;
  }
}
