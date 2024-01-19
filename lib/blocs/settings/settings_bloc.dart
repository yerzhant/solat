import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:solat/models/city.dart';
import 'package:solat/repositories/azan_repository.dart';
import 'package:solat/repositories/solat_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AzanRepository _azanRepository = AzanRepository();
  final SolatRepository _solatRepository;

  SettingsBloc(this._solatRepository) : super(SettingsInProgress()) {
    on<SettingsRequested>((event, emit) async {
      try {
        emit(SettingsInProgress());

        final List<City> cities = await _azanRepository.getCities();
        final fontsScale = await _solatRepository.getFontsScale();
        final azanVolume = await _solatRepository.getAzanVolume();
        final bool requestHidjraDateFromServer =
            await _solatRepository.getRequestHidjraDateFromServer();

        emit(SettingsSuccess(
          cities,
          fontsScale,
          azanVolume,
          requestHidjraDateFromServer,
        ));
      } catch (e) {
        emit(SettingsFailure(e.toString()));
      }
    });

    on<SettingsCitySelected>((event, emit) async {
      try {
        emit(SettingsCitySelectInProgress(
          event.cities,
          event.fontsScale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
        ));

        await _solatRepository.saveCity(event.city);

        emit(SettingsCitySelectSuccess(event.city));
      } on Exception catch (e) {
        emit(SettingsCitySelectFailure(
          event.cities,
          event.fontsScale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
          e.toString(),
        ));
      }
    });

    on<SettingsFontsScaleUpdated>((event, emit) async {
      try {
        await _solatRepository.setFontsScale(event.scale);
        emit(SettingsSuccess(
          event.cities,
          event.scale,
          event.azanVolume,
          event.requestHidjraDateFromServer,
        ));
      } catch (e) {
        emit(SettingsFailure(e.toString()));
      }
    });

    on<SettingsAzanVolumeUpdated>((event, emit) async {
      try {
        await _solatRepository.setAzanVolume(event.volume);
        emit(SettingsSuccess(
          event.cities,
          event.fontScale,
          event.volume,
          event.requestHidjraDateFromServer,
        ));
      } catch (e) {
        emit(SettingsFailure(e.toString()));
      }
    });

    on<SettingsRequestHidjraDateFromServerUpdated>((event, emit) async {
      try {
        await _solatRepository
            .setRequestHidjraDateFromServer(event.requestHidjraDateFromServer);
        emit(SettingsSuccess(
          event.cities,
          event.fontScale,
          event.volume,
          event.requestHidjraDateFromServer,
        ));
      } catch (e) {
        emit(SettingsFailure(e.toString()));
      }
    });
  }
}
