part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;
  final List<City> cities;

  SettingsCitySelected(this.city, this.cities) : assert(city != null);
}
