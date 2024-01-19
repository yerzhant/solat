import 'package:flutter/services.dart';
import 'package:solat/models/city.dart';
import 'package:solat/models/times.dart';

class MainPlatformApi {
  static const cityId = "city-id";
  static const cityName = "city";
  static const latitude = "latitude";
  static const longitude = "longitude";
  static const timeZone = "time-zone";
  static const fontsScale = "fontsScale";
  static const azanVolume = "azanVolume";

  static const currentDateByHidjra = "currentDateByHidjra";
  static const requestHidjraDateFromServer = "request-hidjra-date-from-server";

  static const fadjr = 1;
  static const sunrise = 2;
  static const dhuhr = 3;
  static const asr = 4;
  static const maghrib = 5;
  static const isha = 6;

  static const azanFlagType = "azanFlagType";
  static const azanFlagValue = "azanFlagValue";

  static const errorCityNotSet = "city-not-set";
  static const errorNotEnoughParams = "not-enough-params";
  static const errorNoTimesForToday = "no-times-for-today";

  static const channel = MethodChannel('solat.azan.kz/main');

  Future<Times> getTodayTimes() async {
    final result =
        (await channel.invokeMapMethod<String, String>("get-today-times"))!;
    return Times(
      result[cityName]!,
      result[currentDateByHidjra]!,
      result[fadjr]!,
      result[sunrise]!,
      result[dhuhr]!,
      result[asr]!,
      result[maghrib]!,
      result[isha]!,
    );
  }

  Future<Map<int, bool>> getAzanFlags() async {
    return (await channel.invokeMapMethod<int, bool>('get-azan-flags'))!;
  }

  Future<void> setAzanFlag(type, value) async {
    final params = {azanFlagType: type, azanFlagValue: value};
    await channel.invokeMethod('set-azan-flag', params);
  }

  Future<void> saveCity(City city) {
    final params = {
      cityId: city.id,
      cityName: city.title,
      latitude: city.lat,
      longitude: city.lng,
      timeZone: city.timeZone,
    };
    return channel.invokeMethod("save-city", params);
  }

  Future<double> getFontsScale() async {
    return await channel.invokeMethod('get-fonts-scale');
  }

  Future<void> setFontsScale(double scale) {
    return channel.invokeMethod('set-fonts-scale', {fontsScale: scale});
  }

  Future<double> getAzanVolume() async {
    return await channel.invokeMethod('get-azan-volume');
  }

  Future<void> setAzanVolume(double volume) {
    return channel.invokeMethod('set-azan-volume', {azanVolume: volume});
  }

  Future<bool> getRequestHidjraDateFromServer() async {
    return await channel.invokeMethod('get-request-hidjra-date-from-server');
  }

  Future<void> setRequestHidjraDateFromServer(bool value) {
    return channel.invokeMethod(
      'set-request-hidjra-date-from-server',
      {requestHidjraDateFromServer: value},
    );
  }
}
