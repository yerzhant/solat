part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;
  final List<City> cities;
  final double fontsScale;
  final double azanVolume;

  SettingsCitySelected(
    this.city,
    this.cities,
    this.fontsScale,
    this.azanVolume,
  ) : assert(city != null);
}

class SettingsFontsScaleUpdated extends SettingsEvent {
  final double scale;
  final double azanVolume;
  final List<City> cities;

  SettingsFontsScaleUpdated(this.scale, this.azanVolume, this.cities);
}

class SettingsAzanVolumeUpdated extends SettingsEvent {
  final double volume;
  final double fontScale;
  final List<City> cities;

  SettingsAzanVolumeUpdated(this.volume, this.fontScale, this.cities);
}
