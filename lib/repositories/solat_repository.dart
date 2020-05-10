import 'package:solat/models/times.dart';
import 'package:solat/repositories/main_platform_api.dart';

class SolatRepository {
  final _mainPlatformApi = MainPlatformApi();

  Future<Times> getTodayTimes() {
    return _mainPlatformApi.getTodayTimes();
  }
}
