import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/models/city.dart';
import 'package:solat/repositories/azan_repository.dart';
import 'package:solat/repositories/solat_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AzanRepository _azanRepository = AzanRepository();
  final SolatRepository _solatRepository;
  final TimesBloc _timesBloc;

  StreamSubscription _timesBlocSubscription;

  SettingsBloc(this._solatRepository, this._timesBloc) {
    _timesBlocSubscription = _timesBloc.listen((state) {
      if (state is TimesTodayCityNotSet) {
        add(SettingsRequested());
      }
    });
  }

  @override
  SettingsState get initialState => SettingsInProgress();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsRequested) {
      yield SettingsInProgress();
      try {
        final List<City> cities = await _azanRepository.getCities();
        yield SettingsSuccess(cities);
      } catch (e) {
        yield SettingsFailure(e.toString());
      }
    }
  }

  @override
  Future<void> close() {
    _timesBlocSubscription.cancel();
    return super.close();
  }
}
