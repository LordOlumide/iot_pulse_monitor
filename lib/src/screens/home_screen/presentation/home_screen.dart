import 'package:flutter/material.dart';
import 'package:iot_pulse_monitor/src/data/pulse_repo.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> isConnecting = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isConnecting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isConnecting,
      builder: (context, isConnecting, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!,
            isConnecting
                ? AbsorbPointer(
                    child: Container(
                      color: Colors.white.withOpacity(0.4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Connecting to ${context.read<PulseRepo>().esp32Address}...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
      child: Scaffold(
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
      ),
    );
  }
}
