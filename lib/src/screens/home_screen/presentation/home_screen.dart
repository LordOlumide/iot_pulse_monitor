import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Monitor'),
      ),
      body: Column(
        children: [
          Text(
            'Heart Rate (bpm)',
            style: TextStyle(fontSize: 27),
          ),
        ],
      ),
    );
  }
}
