import 'package:flutter/services.dart';
import 'package:solat/models/city.dart';
import 'package:solat/models/times.dart';

class MainPlatformApi {
  static const cityName = "city";
  static const latitude = "latitude";
  static const longitude = "longitude";
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
    final result = await channel.invokeMapMethod("get-today-times");
    return Times(
      result[cityName],
      result[currentDateByHidjra],
      result[fadjr],
      result[sunrise],
      result[dhuhr],
      result[asr],
      result[maghrib],
      result[isha],
    );
  }

  Future<Map<int, bool>> getAzanFlags() {
    return channel.invokeMapMethod('get-azan-flags');
  }

  Future<void> setAzanFlag(type, value) async {
    final params = {azanFlagType: type, azanFlagValue: value};
    await channel.invokeMethod('set-azan-flag', params);
  }

  Future<void> refreshTimes(City city) {
    final params = {
      cityName: city.title,
      latitude: city.lat,
      longitude: city.lng,
    };
    return channel.invokeMethod("refresh-times", params);
  }

  Future<double> getFontsScale() {
    return channel.invokeMethod('get-fonts-scale');
  }

  Future<void> setFontsScale(double scale) {
    return channel.invokeMethod('set-fonts-scale', {fontsScale: scale});
  }

  Future<double> getAzanVolume() {
    return channel.invokeMethod('get-azan-volume');
  }

  Future<void> setAzanVolume(double volume) {
    return channel.invokeMethod('set-azan-volume', {azanVolume: volume});
  }

  Future<bool> getRequestHidjraDateFromServer() {
    return channel.invokeMethod('get-request-hidjra-date-from-server');
  }

  Future<void> setRequestHidjraDateFromServer(bool value) {
    return channel.invokeMethod(
      'set-request-hidjra-date-from-server',
      {requestHidjraDateFromServer: value},
    );
  }
}
