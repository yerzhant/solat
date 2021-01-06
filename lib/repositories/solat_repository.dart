import 'package:solat/models/city.dart';
import 'package:solat/models/times.dart';
import 'package:solat/repositories/main_platform_api.dart';

class SolatRepository {
  final _mainPlatformApi = MainPlatformApi();

  Future<Times> getTodayTimes() {
    return _mainPlatformApi.getTodayTimes();
  }

  Future<Map<int, bool>> getAzanFlags() {
    return _mainPlatformApi.getAzanFlags();
  }

  Future<void> setAzanFlag(int type, bool value) {
    return _mainPlatformApi.setAzanFlag(type, value);
  }

  Future<void> saveCity(City city) {
    return _mainPlatformApi.saveCity(city);
  }

  Future<double> getFontsScale() {
    return _mainPlatformApi.getFontsScale();
  }

  Future<void> setFontsScale(double scale) {
    return _mainPlatformApi.setFontsScale(scale);
  }

  Future<double> getAzanVolume() {
    return _mainPlatformApi.getAzanVolume();
  }

  Future<void> setAzanVolume(double volume) {
    return _mainPlatformApi.setAzanVolume(volume);
  }

  Future<bool> getRequestHidjraDateFromServer() {
    return _mainPlatformApi.getRequestHidjraDateFromServer();
  }

  Future<void> setRequestHidjraDateFromServer(bool value) {
    return _mainPlatformApi.setRequestHidjraDateFromServer(value);
  }
}
