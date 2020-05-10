import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/pages/home_page.dart';
import 'package:solat/repositories/solat_repository.dart';

void main() {
  runApp(
    RepositoryProvider(
      create: (context) => SolatRepository(),
      child: BlocProvider(
        create: (context) => TimesBloc(context.repository<SolatRepository>())
          ..add(TimesTodayRequested()),
        child: SolatApp(),
      ),
    ),
  );
}

class SolatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Время намаза',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => SettingsBloc(
          context.repository<SolatRepository>(),
          context.bloc<TimesBloc>(),
        ),
        child: HomePage(),
      ),
    );
  }
}
