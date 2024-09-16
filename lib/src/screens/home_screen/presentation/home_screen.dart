import 'package:flutter/material.dart';
import 'package:iot_pulse_monitor/src/data/pulse_repo.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pulseManager = Provider.of<PulseRepo>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Heart Monitor',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 5,
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(height: 25),
            Text(
              'Heart Rate: ${pulseManager.currentBPM} (bpm)',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
