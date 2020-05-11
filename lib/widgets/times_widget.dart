import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:solat/widgets/time_widget.dart';

class TimesWidget extends StatelessWidget {
  const TimesWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimesBloc, TimesState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                color: Color(secondaryColor85),
              ),
              width: 172,
              height: 43,
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
            TimeWidget(
              title: 'Dhuhr',
              time: _getTime(state, 'dhuhr'),
            ),
            TimeWidget(
              title: 'Asr',
              time: _getTime(state, 'asr'),
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
                      text: 'Магриб ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Oswald',
                      ),
                      children: [
                        TextSpan(
                          text: 'через',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '12:34:56',
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
        case 'asr':
          return state.times.asr;
        case 'dhuhr':
          return state.times.dhuhr;
      }
    }
    return '';
  }
}
