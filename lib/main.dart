import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:solat/pages/home_page.dart';
import 'package:solat/repositories/solat_repository.dart';

void main() {
  runApp(
    RepositoryProvider(
      create: (context) => SolatRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TimesBloc(context.read<SolatRepository>())
              ..add(TimesTodayRequested()),
          ),
          BlocProvider(
            create: (context) => SettingsBloc(
              context.read<SolatRepository>(),
              context.read<TimesBloc>(),
            ),
          ),
        ],
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
        colorSchemeSeed: Color(primaryColor),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(primaryColor),
          behavior: SnackBarBehavior.floating,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
