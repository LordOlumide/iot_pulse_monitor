import 'package:flutter/material.dart';
import 'package:iot_pulse_monitor/src/data/pulse_repo.dart';
import 'package:iot_pulse_monitor/src/screens/home_screen/presentation/home_screen.dart';
import 'package:provider/provider.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController hostnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hostnameController.text = 'pulse32';
  }

  @override
  void dispose() {
    hostnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Configuration'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Enter the ESP32 hostname'),
          const SizedBox(height: 5),
          TextField(
            controller: hostnameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _onConnectPressed,
            child: const Text(
              'Connect',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConnectPressed() async {
  //   print('=========== starting request ===================');
  //   if (await context
  //       .read<PulseRepo>()
  //       .discoverEsp32(hostnameController.text)) {
  //     print('=========== Ended request ===================');
  //     if (mounted) {
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const HomeScreen()));
  //     }
  //   }
  // }
}
