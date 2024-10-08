import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/data/config_cubit.dart';
import 'package:iot_pulse_monitor/src/screens/config_screen/presentation/ip_address_container.dart';
import 'package:iot_pulse_monitor/src/screens/home_screen/presentation/home_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController ipAddressController = TextEditingController();
  final FocusNode ipAddressFocusNode = FocusNode();

  List<String> defaultAddresses = ['192.168.118.213'];

  @override
  void dispose() {
    ipAddressController.dispose();
    ipAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigCubit, ConfigState>(
      listener: (context, state) {
        print(state);
        if (state.isConnecting == false && state.avgBpm != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      },
      child: BlocBuilder<ConfigCubit, ConfigState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Network Configuration',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  elevation: 5,
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      const Text('Choose the IP address of your ESP32'),
                      const SizedBox(height: 12),
                      for (String i in defaultAddresses)
                        IpAddressContainer(
                          addr: i,
                          onTap: () => _onConnectToIPAddressPressed(i),
                        ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'OR',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('Enter new ESP32 IP address'),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: ipAddressFocusNode,
                              controller: ipAddressController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _onAddIpAddressPressed,
                            child: const Text('Add',
                                style: TextStyle(fontSize: 19)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              state.isConnecting == true
                  ? AbsorbPointer(
                      child: Container(
                        color: Colors.white.withOpacity(0.4),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Connecting...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 23,
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
      ),
    );
  }

  Future<void> _onAddIpAddressPressed() async {
    setState(() {
      defaultAddresses.add(ipAddressController.text);
      ipAddressController.clear();
      ipAddressFocusNode.unfocus();
    });
  }

  Future<void> _onConnectToIPAddressPressed(String address) async {
    await context.read<ConfigCubit>().connectToWebServer(address);
    await Future.delayed(const Duration(seconds: 5));
  }
}
