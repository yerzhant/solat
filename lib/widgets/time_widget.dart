import 'package:flutter/material.dart';
import 'package:solat/consts.dart';

class TimeWidget extends StatelessWidget {
  final String title;
  final String time;

  const TimeWidget({
    Key key,
    @required this.title,
    @required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = _isActive();

    return Container(
      width: 172,
      height: 34,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: isActive ? Color(secondaryColor) : Color(0xBF232323),
          boxShadow: [
            BoxShadow(
              color: Color(0x996CA5F2),
              blurRadius: 5,
            )
          ]),
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
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'PT Serif',
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  bool _isActive() {
    return true;
  }
}
