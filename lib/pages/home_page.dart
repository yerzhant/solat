import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:solat/pages/settings_page.dart';
import 'package:solat/widgets/times_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

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
      child: BlocBuilder<TimesBloc, TimesState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/masjid-0.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70, bottom: 30),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        child: Image.asset('assets/images/logo.png'),
                        onTap: () => launch('https://azan.kz'),
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
                        onPressed: () => context
                            .bloc<SettingsBloc>()
                            .add(SettingsRequested()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
