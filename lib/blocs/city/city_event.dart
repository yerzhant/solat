part of 'city_bloc.dart';

@immutable
abstract class CityEvent {}

class CityListRequested extends CityEvent {}

class CitySelected extends CityEvent {
  final City city;

  CitySelected(this.city) : assert(city != null);
}
