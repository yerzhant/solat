part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;
  final List<City> cities;
  final double fontsScale;

  SettingsCitySelected(
    this.city,
    this.cities,
    this.fontsScale,
  ) : assert(city != null);
}

class SettingsFontsScaleUpdated extends SettingsEvent {
  final double scale;
  final List<City> cities;

  SettingsFontsScaleUpdated(this.scale, this.cities);
}
