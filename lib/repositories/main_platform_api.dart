import 'package:flutter/services.dart';
import 'package:solat/models/times.dart';

class MainPlatformApi {
  static const city = "city";
  static const latitude = "latitude";
  static const longitude = "longitude";

  static const currentDateByHidjra = "currentDateByHidjra";

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
      result[city],
      result[currentDateByHidjra],
      result[fadjr],
      result[sunrise],
      result[dhuhr],
      result[asr],
      result[maghrib],
      result[isha],
    );
  }
}
