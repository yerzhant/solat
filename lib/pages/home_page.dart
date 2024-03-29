import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:solat/pages/settings_page.dart';
import 'package:solat/widgets/times_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _hidjraWarningShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsInProgress) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/masjid-0.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BlocListener<TimesBloc, TimesState>(
            listener: (context, state) {
              if (state is TimesTodaySuccess &&
                  state.times.dateByHidjra.endsWith('*') &&
                  !_hidjraWarningShown) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Из-за того, что нет доступа к серверу дата по Хиджре может быть неточной.',
                    ),
                    duration: Duration(seconds: 30),
                    onVisible: () {
                      _hidjraWarningShown = true;
                    },
                  ),
                );
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70, bottom: 30),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Image.asset('assets/images/logo.png'),
                      onTap: () => launchUrlString('https://azan.kz'),
                    ),
                    Expanded(
                      child: Center(
                        child: TimesWidget(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: Color(primaryColor),
                      ),
                      onPressed: () =>
                          context.read<SettingsBloc>().add(SettingsRequested()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
