import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:solat/repositories/main_platform_api.dart';
import 'package:solat/widgets/time_widget.dart';

class TimesWidget extends StatelessWidget {
  const TimesWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimesBloc, TimesState>(
      builder: (context, state) {
        final activeType = _getActiveType(state);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                color: Color(secondaryColor85),
              ),
              width: 172,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (state is TimesTodaySuccess)
                    Text(
                      state.times.dateByHidjra,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text('Select city'),
                  if (state is TimesTodaySuccess)
                    Text(
                      state.times.city,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: Color(0xBF232323),
              child: Column(
                children: <Widget>[
                  TimeWidget(
                    title: 'Фаджр',
                    type: MainPlatformApi.fadjr,
                    time: _getTime(state, 'fadjr'),
                    isAzanEnabled: _getFlag(state, 'fadjr'),
                    isActive: activeType == 'fadjr',
                  ),
                  TimeWidget(
                    title: 'Восход',
                    type: MainPlatformApi.sunrise,
                    time: _getTime(state, 'sunrise'),
                    isAzanEnabled: _getFlag(state, 'sunrise'),
                    isActive: activeType == 'sunrise',
                  ),
                  TimeWidget(
                    title: 'Зухр',
                    type: MainPlatformApi.dhuhr,
                    time: _getTime(state, 'dhuhr'),
                    isAzanEnabled: _getFlag(state, 'dhuhr'),
                    isActive: activeType == 'dhuhr',
                  ),
                  TimeWidget(
                    title: 'Аср',
                    type: MainPlatformApi.asr,
                    time: _getTime(state, 'asr'),
                    isAzanEnabled: _getFlag(state, 'asr'),
                    isActive: activeType == 'asr',
                  ),
                  TimeWidget(
                    title: 'Магриб',
                    type: MainPlatformApi.maghrib,
                    time: _getTime(state, 'maghrib'),
                    isAzanEnabled: _getFlag(state, 'maghrib'),
                    isActive: activeType == 'maghrib',
                  ),
                  TimeWidget(
                    title: 'Иша',
                    type: MainPlatformApi.isha,
                    time: _getTime(state, 'isha'),
                    isAzanEnabled: _getFlag(state, 'isha'),
                    isActive: activeType == 'isha',
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                color: Color(secondaryColor85),
              ),
              width: 172,
              height: 37,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      text: _getNextTypeText(activeType),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Oswald',
                      ),
                      children: [
                        TextSpan(
                          text: ' через',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getLeftTime(context, state, activeType),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'PT Serif',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTime(TimesState state, String type) {
    if (state is TimesTodaySuccess) {
      switch (type) {
        case 'fadjr':
          return state.times.fadjr;
        case 'sunrise':
          return state.times.sunrise;
        case 'dhuhr':
          return state.times.dhuhr;
        case 'asr':
          return state.times.asr;
        case 'maghrib':
          return state.times.maghrib;
        case 'isha':
          return state.times.isha;
      }
    }
    return '';
  }

  bool _getFlag(TimesState state, String type) {
    if (state is TimesTodaySuccess) {
      switch (type) {
        case 'fadjr':
          return state.azanFlags[MainPlatformApi.fadjr];
        case 'sunrise':
          return state.azanFlags[MainPlatformApi.sunrise];
        case 'dhuhr':
          return state.azanFlags[MainPlatformApi.dhuhr];
        case 'asr':
          return state.azanFlags[MainPlatformApi.asr];
        case 'maghrib':
          return state.azanFlags[MainPlatformApi.maghrib];
        case 'isha':
          return state.azanFlags[MainPlatformApi.isha];
      }
    }
    return false;
  }

  String _getActiveType(TimesState state) {
    if (state is TimesTodaySuccess) {
      final now = DateTime.now();

      if (_isBefore(now.hour, now.minute, state.times.fadjr)) return 'isha';
      if (_isBefore(now.hour, now.minute, state.times.sunrise)) return 'fadjr';
      if (_isBefore(now.hour, now.minute, state.times.dhuhr)) return 'sunrise';
      if (_isBefore(now.hour, now.minute, state.times.asr)) return 'dhuhr';
      if (_isBefore(now.hour, now.minute, state.times.maghrib)) return 'asr';
      if (_isBefore(now.hour, now.minute, state.times.isha)) return 'maghrib';
      return 'isha';
    }

    return null;
  }

  bool _isBefore(int currentHour, int currentMinute, String time) {
    var hourMinute = _splitTime(time);
    if (currentHour < hourMinute[0]) return true;
    if (currentHour == hourMinute[0] && currentMinute < hourMinute[1])
      return true;

    return false;
  }

  List<int> _splitTime(String time) {
    if (time.isEmpty) return null;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return [hour, minute];
  }

  String _getNextTypeText(String activeType) {
    switch (activeType) {
      case 'fadjr':
        return 'Восход';
      case 'sunrise':
        return 'Зухр';
      case 'dhuhr':
        return 'Аср';
      case 'asr':
        return 'Магриб';
      case 'maghrib':
        return 'Иша';
      case 'isha':
        return 'Фаджр';
      default:
        return '';
    }
  }

  String _getNextType(String activeType) {
    switch (activeType) {
      case 'fadjr':
        return 'sunrise';
      case 'sunrise':
        return 'dhuhr';
      case 'dhuhr':
        return 'asr';
      case 'asr':
        return 'maghrib';
      case 'maghrib':
        return 'isha';
      case 'isha':
        return 'fadjr';
      default:
        return '';
    }
  }

  String _getLeftTime(
    BuildContext context,
    TimesState state,
    String activeType,
  ) {
    final nextTime = _getTime(state, _getNextType(activeType));
    final nextHourMinute = _splitTime(nextTime);
    if (nextHourMinute == null) return '';

    if (state is TimesTodaySuccess) {
      final now = DateTime.now();
      if (now.day != state.day) {
        context.bloc<TimesBloc>().add(TimesTodayRequested());
        return '';
      }

      var dayShift = 0;
      if (activeType == 'isha' && !_isBefore(now.hour, now.minute, nextTime))
        dayShift = 1;

      final next = DateTime(
        now.year,
        now.month,
        now.day + dayShift,
        nextHourMinute[0],
        nextHourMinute[1],
        0,
        0,
        0,
      );
      final diff = next.difference(now).abs();
      return diff.toString().split('.')[0];
    }
    return '';
  }
}
