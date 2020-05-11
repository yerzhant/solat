import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _tapRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _tapRecognizer.onTap = _gotoMuftiyat;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  void _gotoMuftiyat() {
    launch('https://www.muftiyat.kz/kk/namaz_times/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: 'Время намаза предоставлено ',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Духовным управлением мусульман Казахстана',
                  style: TextStyle(color: Colors.blue),
                  recognizer: _tapRecognizer,
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
