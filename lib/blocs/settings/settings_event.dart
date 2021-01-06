part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;
  final List<City> cities;
  final double fontsScale;
  final double azanVolume;
  final bool requestHidjraDateFromServer;

  SettingsCitySelected(
    this.city,
    this.cities,
    this.fontsScale,
    this.azanVolume,
    this.requestHidjraDateFromServer,
  ) : assert(city != null);
}

class SettingsFontsScaleUpdated extends SettingsEvent {
  final double scale;
  final double azanVolume;
  final bool requestHidjraDateFromServer;
  final List<City> cities;

  SettingsFontsScaleUpdated(
    this.scale,
    this.azanVolume,
    this.requestHidjraDateFromServer,
    this.cities,
  );
}

class SettingsAzanVolumeUpdated extends SettingsEvent {
  final double volume;
  final double fontScale;
  final bool requestHidjraDateFromServer;
  final List<City> cities;

  SettingsAzanVolumeUpdated(
    this.volume,
    this.fontScale,
    this.requestHidjraDateFromServer,
    this.cities,
  );
}

class SettingsRequestHidjraDateFromServerUpdated extends SettingsEvent {
  final bool requestHidjraDateFromServer;
  final double volume;
  final double fontScale;
  final List<City> cities;

  SettingsRequestHidjraDateFromServerUpdated(
    this.requestHidjraDateFromServer,
    this.fontScale,
    this.volume,
    this.cities,
  );
}
