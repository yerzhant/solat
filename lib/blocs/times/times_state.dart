part of 'times_bloc.dart';

@immutable
sealed class TimesState {}

class TimesTodayInProgress extends TimesState {}

class TimesTodayCityNotSet extends TimesState {}

class TimesTodaySuccess extends TimesState {
  final int day;
  final Times times;
  final Map<int, bool> azanFlags;

  TimesTodaySuccess(this.day, this.times, this.azanFlags);
}

class TimesTodayFailure extends TimesState {}
