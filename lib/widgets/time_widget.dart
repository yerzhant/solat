import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';

class TimeWidget extends StatelessWidget {
  final String title;
  final String time;
  final int type;
  final bool isAzanEnabled;
  final bool isActive;

  const TimeWidget({
    Key key,
    @required this.title,
    @required this.time,
    @required this.type,
    @required this.isAzanEnabled,
    @required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      height: 34,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(primaryColor) : null,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Color(0x996CA5F2),
              blurRadius: 5,
            ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Oswald',
                fontWeight: isActive ? FontWeight.normal : FontWeight.w100,
              ),
            ),
          ),
          if (time.isNotEmpty)
            IconButton(
              icon: Icon(
                isAzanEnabled ? Icons.volume_up : Icons.volume_off,
                color: isAzanEnabled ? Color(0xFFDDDDDD) : Color(0xFF080808),
                size: 14,
              ),
              onPressed: () {
                BlocProvider.of<TimesBloc>(context).add(
                  TimesAzanFlagSwitched(type, !isAzanEnabled),
                );
              },
            ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'PT Serif',
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
