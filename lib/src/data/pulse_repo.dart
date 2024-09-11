import 'dart:async';
import 'dart:convert';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PulseRepo extends ChangeNotifier {
  String? _esp32Address;

  int _currentBPM = 0;
  int get currentBPM => _currentBPM;

  StreamSubscription<EventFluxData>? bpmStream;

  // Function to connect to the ESP32 webserver and listen for SSE events
  Future<void> connectToWebServer(String ipAddress) async {
    final url = 'http://$ipAddress/events';

    try {
      EventFlux.instance.connect(
        EventFluxConnectionType.get,
        url,
        onSuccessCallback: (EventFluxResponse? response) {
          if (response?.status == EventFluxStatus.connected &&
              response?.stream != null) {
            bpmStream = response?.stream?.listen((data) {
              print(data.data);

              if ((!data.data.contains('hello')) &&
                  Map<String, String>.from(json.decode(data.data))
                      .containsKey('heartrate')) {
                _currentBPM = int.parse(Map<String, String>.from(
                    json.decode(data.data))['heartrate']!);
              }
              notifyListeners();
              // print(Map<String, int>.from(json.decode(data.data)));
            });
          }
        },
        autoReconnect: true,
        reconnectConfig: ReconnectConfig(
          mode: ReconnectMode.linear,
          interval: const Duration(seconds: 5),
          maxAttempts: 1, // or -1 for infinite,
          onReconnect: () {},
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    bpmStream?.cancel();
    super.dispose();
  }

  // Future<bool> discoverEsp32(String esp32Hostname) async {
  //   print('=========== Entered 1 ===================');
  //   // final MDnsClient mdns = MDnsClient();
  //   final MDnsClient mdns = MDnsClient(rawDatagramSocketFactory:
  //       (dynamic host, int port,
  //           {bool? reuseAddress, bool? reusePort, int? ttl}) {
  //     print('=========== Entered 2 ===================');
  //     return RawDatagramSocket.bind(host, port,
  //         reuseAddress: true, reusePort: false, ttl: ttl!);
  //   });
  //   print('=========== Entered 3 ===================');
  //   await mdns.start();
  //   print('=========== Entered 4 ===================');
  //
  //   try {
  //     print('=========== Entered 5 ===================');
  //     // Look for a service matching '_http._tcp.local'
  //     await for (PtrResourceRecord ptr in mdns.lookup<PtrResourceRecord>(
  //         ResourceRecordQuery.serverPointer('$esp32Hostname._tcp.local'))) {
  //       // Look for the matching service details.
  //
  //       print('=========== Entered 6 ===================');
  //       await for (SrvResourceRecord srv in mdns.lookup<SrvResourceRecord>(
  //           ResourceRecordQuery.service(ptr.domainName))) {
  //         print('Found service: ${srv.target}');
  //         esp32Address = 'http://${srv.target}.local:${srv.port}';
  //         print(esp32Address);
  //
  //         break;
  //       }
  //       print('=========== Entered 7 ===================');
  //     }
  //     print('=========== Entered 8 ===================');
  //   } catch (e) {
  //     print('=========== Entered 9 ===================');
  //     print(e);
  //   } finally {
  //     print('=========== Entered 10 ===================');
  //     // Finally still runs even if there is a return statement in the try-catch
  //     mdns.stop();
  //   }
  //   return esp32Address.isNotEmpty ? true : false;
  // }

  Future<Map<String, int>> fetchData() async {
    if (_esp32Address?.isNotEmpty ?? false) {
      final response = await http.get(Uri.parse('$_esp32Address/data'));

      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body));
      } else {
        print(response);
        throw Exception('========== Error fetching data ============');
      }
    } else {
      throw Exception('========== ESP32 Not found ============');
    }
  }
}
