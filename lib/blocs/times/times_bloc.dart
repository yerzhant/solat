import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:solat/models/city.dart';
import 'package:solat/models/times.dart';
import 'package:solat/repositories/solat_repository.dart';

part 'times_event.dart';
part 'times_state.dart';

class TimesBloc extends Bloc<TimesEvent, TimesState> {
  final _solatRepository = SolatRepository();

  @override
  TimesState get initialState => TimesInitial();

  @override
  Stream<TimesState> mapEventToState(TimesEvent event) async* {
    if (event is TimesTodayRequested) {
      yield TimesTodayInProgress();
      try {
        final times = await _solatRepository.getTodayTimes();
        yield TimesTodaySuccess(times);
      } catch (_) {
        yield TimesTodayFailure();
      }
    }
  }
}
