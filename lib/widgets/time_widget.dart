import 'package:flutter/material.dart';
import 'package:solat/consts.dart';

class TimeWidget extends StatelessWidget {
  final String title;
  final String time;
  final bool isActive;

  const TimeWidget({
    Key key,
    @required this.title,
    @required this.time,
    @required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      height: 34,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(secondaryColor) : null,
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
}
