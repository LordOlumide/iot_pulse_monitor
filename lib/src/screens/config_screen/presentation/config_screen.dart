import 'package:flutter/material.dart';
import 'package:iot_pulse_monitor/src/data/pulse_repo.dart';
import 'package:iot_pulse_monitor/src/screens/config_screen/presentation/ip_address_container.dart';
import 'package:iot_pulse_monitor/src/screens/home_screen/presentation/home_screen.dart';
import 'package:provider/provider.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController ipAddressController = TextEditingController();
  final FocusNode ipAddressFocusNode = FocusNode();

  bool isConnecting = false;

  List<String> defaultAddresses = ['192.168.118.213'];

  @override
  void initState() {
    super.initState();
    context.read<PulseRepo>().addListener(connectionListener);
  }

  void connectionListener() async {
    if (context.read<PulseRepo>().bpmStream != null) {
      context.read<PulseRepo>().removeListener(connectionListener);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    ipAddressController.dispose();
    ipAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
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
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _onAddIpAddressPressed,
                      child: const Text('Add', style: TextStyle(fontSize: 19)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        isConnecting
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
  }

  Future<void> _onAddIpAddressPressed() async {
    setState(() {
      defaultAddresses.add(ipAddressController.text);
      ipAddressController.clear();
      ipAddressFocusNode.unfocus();
    });
  }

  Future<void> _onConnectToIPAddressPressed(String address) async {
    setState(() {
      isConnecting = true;
    });
    await context.read<PulseRepo>().connectToWebServer(address);
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isConnecting = false;
    });
  }
}
