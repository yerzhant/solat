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
        final azanVolume = await _solatRepository.getAzanVolume();
        final bool requestHidjraDateFromServer =
            await _solatRepository.getRequestHidjraDateFromServer();

        yield SettingsSuccess(
          cities,
          fontsScale,
          azanVolume,
          requestHidjraDateFromServer,
        );
      } catch (e) {
        yield SettingsFailure(e.toString());
      }
    } else if (event is SettingsCitySelected) {
      try {
        yield SettingsCitySelectInProgress(
          event.cities,
          event.fontsScale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
        );

        await _solatRepository.saveCity(event.city);

        yield SettingsCitySelectSuccess(event.city);
      } on Exception catch (e) {
        yield SettingsCitySelectFailure(
          event.cities,
          event.fontsScale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
          e.toString(),
        );
      }
    } else if (event is SettingsFontsScaleUpdated) {
      try {
        await _solatRepository.setFontsScale(event.scale);
        yield SettingsSuccess(
          event.cities,
          event.scale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
        );
      } catch (e) {
        yield SettingsFailure(e.toString());
      }
    } else if (event is SettingsAzanVolumeUpdated) {
      try {
        await _solatRepository.setAzanVolume(event.volume);
        yield SettingsSuccess(
          event.cities,
          event.fontScale,
          event.volume,
          event.requestHidjraDateFromServer,
        );
      } catch (e) {
        yield SettingsFailure(e.toString());
      }
    } else if (event is SettingsRequestHidjraDateFromServerUpdated) {
      try {
        await _solatRepository
            .setRequestHidjraDateFromServer(event.requestHidjraDateFromServer);
        yield SettingsSuccess(
          event.cities,
          event.fontScale,
          event.volume,
          event.requestHidjraDateFromServer,
        );
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
