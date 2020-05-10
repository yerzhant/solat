part of 'city_bloc.dart';

@immutable
abstract class CityState {}

class CityInitial extends CityState {}

class CityListInProgress extends CityState {}

class CityListSuccess extends CityState {
  final List<City> cities;

  CityListSuccess(this.cities);
}

class CityListFailure extends CityState {}

class CitySelectSuccess extends CityState {
  final City city;

  CitySelectSuccess(this.city);
}
