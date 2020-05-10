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
