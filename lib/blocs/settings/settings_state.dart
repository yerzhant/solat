part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInProgress extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final List<City> cities;
  final double fontsScale;

  SettingsSuccess(this.cities, this.fontsScale);
}

class SettingsFailure extends SettingsState {
  final String message;

  SettingsFailure(this.message);
}

class SettingsCitySelectInProgress extends SettingsSuccess {
  SettingsCitySelectInProgress(
    List<City> cities,
    double fontsScale,
  ) : super(cities, fontsScale);
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
    this.message,
  ) : super(cities, fontsScale);
}
