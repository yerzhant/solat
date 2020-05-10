import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/pages/settings_page.dart';

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
          return Container(
            child: Text('Main page'),
          );
        },
      ),
    );
  }
}
