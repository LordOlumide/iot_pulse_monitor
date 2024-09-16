part of './config_cubit.dart';

class ConfigState extends Equatable {
  final bool isConnecting;
  final bool isFingerDetected;
  final int irValue;
  final int avgBpm;
  final int bpm;
  final Failure? error;

  const ConfigState({
    required this.isConnecting,
    required this.isFingerDetected,
    required this.irValue,
    required this.avgBpm,
    required this.bpm,
    this.error,
  });

  ConfigState copyWith({
    bool? isConnecting,
    bool? isFingerDetected,
    int? irValue,
    int? avgBpm,
    int? bpm,
    Failure? error,
  }) {
    return ConfigState(
      isConnecting: isConnecting ?? this.isConnecting,
      isFingerDetected: isFingerDetected ?? this.isFingerDetected,
      irValue: irValue ?? this.irValue,
      avgBpm: avgBpm ?? this.avgBpm,
      bpm: bpm ?? this.bpm,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [isConnecting, isFingerDetected, irValue, avgBpm, bpm, error];
}
