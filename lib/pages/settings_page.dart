import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/repositories/solat_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityNameController = TextEditingController();
  final _tapRecognizer = TapGestureRecognizer();
  String _selectedCity;

  @override
  void initState() {
    super.initState();
    _tapRecognizer.onTap = _gotoMuftiyat;
  }

  @override
  void dispose() {
    _cityNameController.dispose();
    _tapRecognizer.dispose();
    super.dispose();
  }

  void _gotoMuftiyat() {
    launch('https://www.muftiyat.kz/kk/namaz_times/');
  }

  @override
  Widget build(BuildContext context) {
    final timesState = context.bloc<TimesBloc>().state;
    if (timesState is TimesTodaySuccess) {
      _cityNameController.text = timesState.times.city;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsInProgress) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is SettingsSuccess) {
                    return _form(state);
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Время намаза предоставлено ',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Духовным управлением мусульман Казахстана',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    recognizer: _tapRecognizer,
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Form _form(SettingsSuccess state) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _cityNameController,
              decoration: InputDecoration(labelText: 'Город'),
            ),
            onSuggestionSelected: (value) {
              _cityNameController.text = value;
            },
            itemBuilder: (_, value) {
              return ListTile(
                title: Text(value),
              );
            },
            suggestionsCallback: (pattern) => _filterCities(pattern, state),
            validator: (value) {
              if (value.isEmpty) {
                return 'Введите город';
              }
              if (!state.cities
                  .map((e) => e.title)
                  .any((c) => c.toLowerCase() == value.toLowerCase())) {
                return 'Указанный город не найден';
              }
              return null;
            },
            onSaved: (newValue) => _selectedCity = newValue,
            noItemsFoundBuilder: (context) =>
                ListTile(title: Text('Не найдено')),
          ),
          SizedBox(height: 15),
          Builder(
            builder: (context) => RaisedButton(
              child: Text('Обновить'),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  final city = state.cities.firstWhere((element) =>
                      element.title.toLowerCase() ==
                      _selectedCity.toLowerCase());

                  try {
                    await context
                        .repository<SolatRepository>()
                        .refreshTimes(city);

                    context.bloc<TimesBloc>().add(TimesTodayRequested());

                    Navigator.of(context).pop();
                  } catch (e) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка: $e'),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _filterCities(String pattern, SettingsSuccess state) {
    return state.cities
        .map((e) => e.title)
        .where((element) =>
            element.toLowerCase().startsWith(pattern.toLowerCase()))
        .toList();
  }
}
