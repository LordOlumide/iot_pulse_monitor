import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:eventflux/eventflux.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/utils/utils_barrel.dart';

part './config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  ConfigCubit()
      : super(
          const ConfigState(
            isConnecting: false,
            isFingerDetected: false,
            irValue: 0,
            avgBpm: 0,
            bpm: 0,
          ),
        );

  // Stream<Map<String, dynamic>>? valuesStream;

  // Function to connect to the ESP32 webserver and listen for SSE events
  Future<void> connectToWebServer(String ipAddress) async {
    final url = 'http://$ipAddress/events';

    emit(state.copyWith(isConnecting: true));
    try {
      EventFlux.instance.connect(
        EventFluxConnectionType.get,
        url,
        onSuccessCallback: (EventFluxResponse? response) {
          if (response?.status == EventFluxStatus.connected &&
              response?.stream != null) {
            response?.stream?.forEach((data) {
              print(data.data);

              if (!data.data.contains('hello')) {
                Map<String, dynamic> decodedData =
                    Map<String, dynamic>.from(json.decode(data.data));

                if (decodedData.containsKey('avgBPM')) {
                  emit(
                    ConfigState(
                      isConnecting: false,
                      isFingerDetected: decodedData['isFingerDetected']!,
                      irValue: decodedData['IR-value']!,
                      avgBpm: decodedData['avgBPM']!,
                      bpm: decodedData['bpm']!,
                    ),
                  );
                }
              }
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
      emit(state.copyWith(error: Failure(message: e.toString())));
    }
    emit(state.copyWith(isConnecting: false));
  }
}
