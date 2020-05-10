import 'dart:async';

import 'package:bloc/bloc.dart';
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

  TimesBloc(this._solatRepository);

  @override
  TimesState get initialState => TimesTodayInProgress();

  @override
  Stream<TimesState> mapEventToState(TimesEvent event) async* {
    if (event is TimesTodayRequested) {
      yield TimesTodayInProgress();
      try {
        final times = await _solatRepository.getTodayTimes();
        print(times);
        yield TimesTodaySuccess(times);
      } on PlatformException catch (e) {
        if (e.code == MainPlatformApi.errorCityNotSet ||
            e.code == MainPlatformApi.errorNoTimesForToday)
          yield TimesTodayCityNotSet();
        else
          yield TimesTodayFailure();
      }
    }
  }
}
