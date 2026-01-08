part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

class SettingsInProgress extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final List<City> cities;
  final double fontsScale;
  final double azanVolume;
  final double bgOpacity;
  final bool requestHidjraDateFromServer;

  SettingsSuccess(
    this.cities,
    this.fontsScale,
    this.azanVolume,
    this.bgOpacity,
    this.requestHidjraDateFromServer,
  );
}

class SettingsFailure extends SettingsState {
  final String message;

  SettingsFailure(this.message);
}

class SettingsCitySelectInProgress extends SettingsSuccess {
  SettingsCitySelectInProgress(
    List<City> cities,
    double fontsScale,
    double azanVolume,
    double bgOpacity,
    bool requestHidjraDateFromServer,
  ) : super(
          cities,
          fontsScale,
          azanVolume,
          bgOpacity,
          requestHidjraDateFromServer,
        );
}

class SettingsCitySelectSuccess extends SettingsState {
  final City city;

  SettingsCitySelectSuccess(this.city);
}

class SettingsCitySelectFailure extends SettingsSuccess {
  final String message;

  SettingsCitySelectFailure(
    List<City> cities,
    double fontsScale,
    double azanVolume,
    double bgOpacity,
    bool requestHidjraDateFromServer,
    this.message,
  ) : super(
          cities,
          fontsScale,
          azanVolume,
          bgOpacity,
          requestHidjraDateFromServer,
        );
}
