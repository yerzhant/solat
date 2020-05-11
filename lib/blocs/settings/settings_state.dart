part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInProgress extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final List<City> cities;

  SettingsSuccess(this.cities);
}

class SettingsFailure extends SettingsState {
  final String message;

  SettingsFailure(this.message);
}

class SettingsCitySelectSuccess extends SettingsState {
  final City city;

  SettingsCitySelectSuccess(this.city);
}

class SettingsCitySelectFailure extends SettingsSuccess {
  final String message;

  SettingsCitySelectFailure(List<City> cities, this.message) : super(cities);
}
