part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

class SettingsRequested extends SettingsEvent {}

class SettingsCitySelected extends SettingsEvent {
  final City city;
  final List<City> cities;
  final double fontsScale;
  final double azanVolume;
  final double bgOpacity;
  final bool requestHidjraDateFromServer;

  SettingsCitySelected(
    this.city,
    this.cities,
    this.fontsScale,
    this.azanVolume,
    this.bgOpacity,
    this.requestHidjraDateFromServer,
  );
}

class SettingsFontsScaleUpdated extends SettingsEvent {
  final double scale;
  final double azanVolume;
  final double bgOpacity;
  final bool requestHidjraDateFromServer;
  final List<City> cities;

  SettingsFontsScaleUpdated(
    this.scale,
    this.azanVolume,
    this.bgOpacity,
    this.requestHidjraDateFromServer,
    this.cities,
  );
}

class SettingsAzanVolumeUpdated extends SettingsEvent {
  final double volume;
  final double fontScale;
  final double bgOpacity;
  final bool requestHidjraDateFromServer;
  final List<City> cities;

  SettingsAzanVolumeUpdated(
    this.volume,
    this.fontScale,
    this.bgOpacity,
    this.requestHidjraDateFromServer,
    this.cities,
  );
}

class SettingsBgOpacityUpdated extends SettingsEvent {
  final double opacity;
  final double fontScale;
  final double azanVolume;
  final bool requestHidjraDateFromServer;
  final List<City> cities;

  SettingsBgOpacityUpdated(
    this.opacity,
    this.fontScale,
    this.azanVolume,
    this.requestHidjraDateFromServer,
    this.cities,
  );
}

class SettingsRequestHidjraDateFromServerUpdated extends SettingsEvent {
  final bool requestHidjraDateFromServer;
  final double fontScale;
  final double azanVolume;
  final double bgOpacity;
  final List<City> cities;

  SettingsRequestHidjraDateFromServerUpdated(
    this.requestHidjraDateFromServer,
    this.fontScale,
    this.azanVolume,
    this.bgOpacity,
    this.cities,
  );
}
