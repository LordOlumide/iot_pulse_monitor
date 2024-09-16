import 'package:iot_pulse_monitor/src/utils/error/failure.dart';
import 'package:iot_pulse_monitor/src/utils/state_mgmt/base/bloc_state.dart';

abstract class BlocStateWithStatus extends BlocState {
  final bool success;
  final bool loading;
  final Failure? error;

  const BlocStateWithStatus({
    required this.success,
    required this.loading,
    required this.error,
  });

  dynamic copyWith({
    bool? success,
    bool? loading,
    Failure? error,
  });
}
