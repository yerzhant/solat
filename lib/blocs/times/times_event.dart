part of 'times_bloc.dart';

@immutable
abstract class TimesEvent {}

class TimesTodayRequested extends TimesEvent {}

class TimesTodayTicked extends TimesEvent {}

class TimesRefreshed extends TimesEvent {
  final City city;

  TimesRefreshed(this.city) : assert(city != null);
}
