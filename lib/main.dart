import 'package:flutter/material.dart';
import 'package:iot_pulse_monitor/src/data/pulse_repo.dart';
import 'package:iot_pulse_monitor/src/screens/home_screen/presentation/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<PulseRepo>(
      create: (context) => PulseRepo(),
      child: MaterialApp(
        title: 'IOT Pulse Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
