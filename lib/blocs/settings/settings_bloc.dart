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
      try {
        yield SettingsInProgress();

        final List<City> cities = await _azanRepository.getCities();
        final fontsScale = await _solatRepository.getFontsScale();

        yield SettingsSuccess(cities, fontsScale);
      } catch (e) {
        yield SettingsFailure(e.toString());
      }
    } else if (event is SettingsCitySelected) {
      try {
        yield SettingsCitySelectInProgress(event.cities, event.fontsScale);

        await _solatRepository.refreshTimes(event.city);

        yield SettingsCitySelectSuccess(event.city);
      } on Exception catch (e) {
        yield SettingsCitySelectFailure(
          event.cities,
          event.fontsScale,
          e.toString(),
        );
      }
    } else if (event is SettingsFontsScaleUpdated) {
      try {
        await _solatRepository.setFontsScale(event.scale);
        yield SettingsSuccess(event.cities, event.scale);
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
