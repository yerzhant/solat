import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solat/models/city.dart';

class AzanApi {
  static const _baseUrl = 'https://azan.kz/api';

  Future<List<City>> getCities() async {
    final response = await http.get('$_baseUrl/asr/cities');

    if (response.statusCode != 200) {
      throw Exception('Unable to get cities: ${response.statusCode}');
    }

    final jsonList = jsonDecode(
      response.body,
      reviver: (key, value) => value is int ? value.toDouble() : value,
    ) as List;

    final cities = <City>[];
    cities.addAll(jsonList.map((e) => City.fromJson(e)));

    return cities;
  }
}
