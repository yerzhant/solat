import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:solat/models/city.dart';
import 'package:solat/models/times.dart';
import 'package:solat/repositories/main_platform_api.dart';
import 'package:solat/repositories/solat_repository.dart';

part 'times_event.dart';
part 'times_state.dart';

class TimesBloc extends Bloc<TimesEvent, TimesState> {
  final SolatRepository _solatRepository;
  StreamSubscription _ticker;

  TimesBloc(this._solatRepository);

  @override
  TimesState get initialState => TimesTodayInProgress();

  @override
  Stream<TimesState> mapEventToState(TimesEvent event) async* {
    if (event is TimesTodayRequested) {
      _ticker?.cancel();
      yield TimesTodayInProgress();
      try {
        final times = await _solatRepository.getTodayTimes();
        final azanFlags = await _solatRepository.getAzanFlags();
        yield TimesTodaySuccess(DateTime.now().day, times, azanFlags);
        _startTicker();
      } on PlatformException catch (e) {
        if (e.code == MainPlatformApi.errorCityNotSet ||
            e.code == MainPlatformApi.errorNoTimesForToday)
          yield TimesTodayCityNotSet();
        else
          yield TimesTodayFailure();
      }
    } else if (event is TimesTodayTicked) {
      final currentState = state as TimesTodaySuccess;
      yield TimesTodaySuccess(
        currentState.day,
        currentState.times,
        currentState.azanFlags,
      );
    } else if (event is TimesAzanFlagSwitched) {
      await _solatRepository.setAzanFlag(event.type, event.value);
      final azanFlags = await _solatRepository.getAzanFlags();
      final currentState = state as TimesTodaySuccess;
      yield TimesTodaySuccess(
        currentState.day,
        currentState.times,
        azanFlags,
      );
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Stream.periodic(
      Duration(seconds: 1),
    ).listen((_) {
      add(TimesTodayTicked());
    });
  }
}
