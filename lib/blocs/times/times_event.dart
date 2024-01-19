part of 'times_bloc.dart';

@immutable
sealed class TimesEvent {}

class TimesTodayRequested extends TimesEvent {}

class TimesTodayTicked extends TimesEvent {}

class TimesAzanFlagSwitched extends TimesEvent {
  final int type;
  final bool value;

  TimesAzanFlagSwitched(this.type, this.value);
}

class TimesRefreshed extends TimesEvent {
  final City city;

  TimesRefreshed(this.city);
}
