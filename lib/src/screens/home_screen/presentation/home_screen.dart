import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/data/config_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<ConfigCubit, ConfigState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  Text(
                    state.isFingerDetected == true
                        ? 'Finger Detected'
                        : 'No Finger Detected!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: state.isFingerDetected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Average Heart Rate (bpm):',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.avgBpm.toString(),
                    style: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 70),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Infrared value: ${state.irValue}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'BPM: ${state.bpm} (bpm)',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
