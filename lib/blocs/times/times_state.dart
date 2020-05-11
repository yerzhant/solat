part of 'times_bloc.dart';

@immutable
abstract class TimesState {}

class TimesTodayInProgress extends TimesState {}

class TimesTodayCityNotSet extends TimesState {}

class TimesTodaySuccess extends TimesState {
  final Times times;
  final Map<int, bool> azanFlags;

  TimesTodaySuccess(this.times, this.azanFlags);
}

class TimesTodayFailure extends TimesState {}

class TimesRefreshInProgress extends TimesState {}

class TimesRefreshSuccess extends TimesState {}

class TimesRefreshFailure extends TimesState {}
