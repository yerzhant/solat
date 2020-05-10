import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/pages/home_page.dart';

void main() {
  runApp(SolatApp());
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
        create: (_) => TimesBloc(),
        child: HomePage(),
      ),
    );
  }
}
