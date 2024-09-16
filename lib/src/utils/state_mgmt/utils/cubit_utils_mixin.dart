import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_pulse_monitor/src/utils/error/failure.dart';
import 'package:iot_pulse_monitor/src/utils/state_mgmt/base/state_with_status.dart';

mixin CubitUtilsMixin<State extends BlocStateWithStatus> on Cubit<State> {
  void emitOnError(Failure error) {
    emit(state.copyWith(error: error, loading: false, success: false));
  }

  void emitLoading([bool nullifyError = true]) {
    emit(
      state.copyWith(
        loading: true,
        success: false,
        error: nullifyError ? null : state.error,
      ),
    );
  }

  void emitNotLoading([bool nullifyError = true]) {
    emit(
      state.copyWith(
        loading: false,
        success: false,
        error: nullifyError ? null : state.error,
      ),
    );
  }

  void emitSuccess({
    State? state,
    bool nullifyError = true,
  }) {
    emit(
      (state ?? this.state).copyWith(
        success: true,
        loading: false,
        error: nullifyError ? null : (state ?? this.state).error,
      ),
    );
  }
}
