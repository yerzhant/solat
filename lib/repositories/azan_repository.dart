import 'package:solat/models/city.dart';
import 'package:solat/repositories/azan_api.dart';

class AzanRepository {
  final _azanApi = AzanApi();

  Future<List<City>> getCities() => _azanApi.getCities();
}
