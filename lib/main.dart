import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/data/config_cubit.dart';
import 'package:iot_pulse_monitor/src/screens/config_screen/presentation/config_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfigCubit>(
      create: (context) => ConfigCubit(),
      child: MaterialApp(
        title: 'IOT Pulse Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ConfigScreen(),
      ),
    );
  }
}
