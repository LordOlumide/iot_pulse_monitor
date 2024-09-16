import 'dart:async';
import 'dart:convert';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';

class PulseRepo extends ChangeNotifier {
  int _currentBPM = 0;
  int get currentBPM => _currentBPM;

  bool freshlyConnected = false;

  StreamSubscription<Map<String, int>>? bpmStream;

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
            bpmStream = response?.stream?.map<Map<String, int>>((data) {
              print(data.data);

              if (!data.data.contains('hello')) {
                Map<String, String> decodedData =
                    Map<String, String>.from(json.decode(data.data));

                if (decodedData.containsKey('heartrate')) {
                  return {'heartrate': int.parse(decodedData['heartrate']!)};
                } else {
                  return {};
                }
              } else {
                return {};
              }
            }).listen((mappedData) {
              if (mappedData.containsKey('heartrate')) {
                _currentBPM = mappedData['heartrate']!;
              }
              freshlyConnected = true;
              notifyListeners();
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
}
