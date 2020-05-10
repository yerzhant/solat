part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;

  SettingsCitySelected(this.city) : assert(city != null);
}
