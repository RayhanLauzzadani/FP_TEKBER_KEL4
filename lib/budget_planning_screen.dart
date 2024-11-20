import 'package:flutter/material.dart';

class BudgetPlanningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planning'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Budget Planning Screen Content Goes Here',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
