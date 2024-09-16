import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:eventflux/eventflux.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/utils/utils_barrel.dart';
import 'package:permission_handler/permission_handler.dart';

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
    try {
      await Permission.nearbyWifiDevices.request();

      final url = 'http://$ipAddress/events';

      emit(state.copyWith(isConnecting: true));

      EventFlux.instance.connect(
        EventFluxConnectionType.get,
        url,
        onSuccessCallback: (EventFluxResponse? response) {
          if (response?.status == EventFluxStatus.connected &&
              response?.stream != null) {
            response?.stream?.listen(
              (data) {
                developer.log('Received data: ${data.data}', name: 'SSE');

                if (!data.data.contains('hello')) {
                  try {
                    Map<String, dynamic> decodedData =
                        Map<String, dynamic>.from(json.decode(data.data));

                    if (decodedData.containsKey('avgBPM')) {
                      emit(
                        ConfigState(
                          isConnecting: false,
                          isFingerDetected:
                              decodedData['isFingerDetected'] ?? false,
                          irValue: decodedData['IR-value'] ?? 0,
                          avgBpm: decodedData['avgBPM'] ?? 0,
                          bpm: decodedData['bpm'] ?? 0,
                        ),
                      );
                    }
                  } catch (e) {
                    developer.log('Error decoding JSON: $e',
                        name: 'SSE', error: e);
                  }
                }
              },
              onError: (error) {
                developer.log('Stream error: $error',
                    name: 'SSE', error: error);
                emit(state.copyWith(error: Failure(message: error.toString())));
              },
            );
          }
        },
        onError: (error) {
          developer.log('Connection error: $error', name: 'SSE', error: error);
          emit(state.copyWith(error: Failure(message: error.toString())));
        },
        autoReconnect: true,
        reconnectConfig: ReconnectConfig(
          mode: ReconnectMode.linear,
          interval: const Duration(seconds: 5),
          maxAttempts: 1, // or -1 for infinite
          onReconnect: () {
            developer.log('Attempting to reconnect', name: 'SSE');
          },
        ),
      );
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'SSE', error: e);
      emit(state.copyWith(error: Failure(message: e.toString())));
    } finally {
      emit(state.copyWith(isConnecting: false));
    }
  }
}
