import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:solat/blocs/settings/settings_bloc.dart';
import 'package:solat/blocs/times/times_bloc.dart';
import 'package:solat/consts.dart';
import 'package:url_launcher/url_launcher_string.dart';

const fontsScaleMin = 0.8;
const fontsScaleMax = 1.2;
const fontsScaleDefault = 1.0;
const fontsScaleSteps = 10;

const azanVolumeMin = 0.0;
const azanVolumeMax = 1.0;
const azanVolumeDefault = .3;
const azanVolumeSteps = 30;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityNameController = TextEditingController();

  final _muftiyatTapRecognizer = TapGestureRecognizer();

  String? _selectedCity;

  var _fontsScale = fontsScaleDefault;
  var _fontsScaling = false;
  String? _fontScaleLabel = 'По умолчанию';
  var _fontScaleColor = Color(primaryColor);

  var _azanVolume = azanVolumeDefault;
  var _azanVolumeUpdating = false;
  String? _azanVolumeLabel = 'По умолчанию';

  @override
  void initState() {
    super.initState();
    _muftiyatTapRecognizer.onTap = _gotoMuftiyat;
  }

  @override
  void dispose() {
    _cityNameController.dispose();
    _muftiyatTapRecognizer.dispose();
    super.dispose();
  }

  void _gotoMuftiyat() {
    launchUrlString('https://www.muftyat.kz/kk/namaz_times/');
  }

  @override
  Widget build(BuildContext context) {
    final timesState = context.read<TimesBloc>().state;
    if (timesState is TimesTodaySuccess) {
      _cityNameController.text = timesState.times.city;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  BlocConsumer<SettingsBloc, SettingsState>(
                    listener: (context, state) {
                      if (state is SettingsCitySelectFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка: ${state.message}')),
                        );
                      } else if (state is SettingsCitySelectSuccess) {
                        context.read<TimesBloc>().add(TimesTodayRequested());
                        Navigator.of(context).pop();
                      }
                    },
                    builder: (context, state) {
                      if (state is SettingsSuccess) {
                        if (!_fontsScaling) {
                          _fontsScale = state.fontsScale;

                          if (_fontsScale < fontsScaleMin)
                            _fontsScale = fontsScaleMin;
                          else if (_fontsScale > fontsScaleMax)
                            _fontsScale = fontsScaleMax;

                          _setFontScalerColor(_fontsScale);
                        }

                        if (!_azanVolumeUpdating) {
                          _azanVolume = state.azanVolume;

                          if (_azanVolume < azanVolumeMin)
                            _azanVolume = azanVolumeMin;
                          else if (_azanVolume > azanVolumeMax)
                            _azanVolume = azanVolumeMax;
                        }
                      }
                      return Column(
                        children: [
                          if (state is SettingsInProgress)
                            Center(child: CircularProgressIndicator())
                          else if (state is SettingsSuccess ||
                              state is SettingsCitySelectInProgress ||
                              state is SettingsCitySelectFailure)
                            _form(state as SettingsSuccess)
                          else
                            Text('Нет соединения с сервером.'),
                          SizedBox(height: 15),
                          _setupSettingsButton(),
                          SizedBox(height: widgetItemPadding + 13),
                          if (state is SettingsSuccess)
                            Column(
                              children: [
                                if (defaultTargetPlatform ==
                                    TargetPlatform.android) ...[
                                  Text('Размер шрифта виджета'),
                                  _fontSizeSlider(context, state),
                                  SizedBox(height: widgetItemPadding),
                                  Text('Громкость азана'),
                                  _azanVolumeSlider(context, state),
                                ],
                                _hidjrahDateSource(state, context),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                  Spacer(),
                  _aNote(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _setupSettingsButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: FilledButton(
            child: Text('НАСТРОЙКА УВЕДОМЛЕНИЙ'),
            onPressed: () => AppSettings.openAppSettings(),
          ),
        ),
      ],
    );
  }

  Slider _fontSizeSlider(BuildContext context, SettingsSuccess state) {
    return Slider(
      min: fontsScaleMin,
      max: fontsScaleMax,
      divisions: fontsScaleSteps,
      value: _fontsScale,
      label: _fontScaleLabel,
      activeColor: _fontScaleColor,
      onChanged: (value) {
        setState(() {
          _fontsScaling = true;
          _fontsScale = value;

          _setFontScalerColor(value);
        });
      },
      onChangeEnd: (value) {
        _fontsScaling = false;

        context.read<SettingsBloc>().add(
              SettingsFontsScaleUpdated(
                value,
                state.azanVolume,
                state.requestHidjraDateFromServer,
                state.cities,
              ),
            );
      },
    );
  }

  Slider _azanVolumeSlider(BuildContext context, SettingsSuccess state) {
    return Slider(
      min: azanVolumeMin,
      max: azanVolumeMax,
      divisions: azanVolumeSteps,
      value: _azanVolume,
      label: _azanVolumeLabel,
      activeColor: Color(primaryColor),
      onChanged: (value) {
        setState(() {
          _azanVolumeUpdating = true;
          _azanVolume = value;
          _setAzanVolumeLabel(value);
        });
      },
      onChangeEnd: (value) {
        _azanVolumeUpdating = false;

        context.read<SettingsBloc>().add(
              SettingsAzanVolumeUpdated(
                value,
                state.fontsScale,
                state.requestHidjraDateFromServer,
                state.cities,
              ),
            );
      },
    );
  }

  CheckboxListTile _hidjrahDateSource(
      SettingsSuccess state, BuildContext context) {
    return CheckboxListTile(
      value: state.requestHidjraDateFromServer,
      title: Text(
        'Получать дату по Хиджре с azan.kz',
        style: TextStyle(fontSize: 14),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) {
        context.read<SettingsBloc>().add(
              SettingsRequestHidjraDateFromServerUpdated(
                value!,
                state.fontsScale,
                state.azanVolume,
                state.cities,
              ),
            );

        context.read<TimesBloc>().add(TimesTodayRequested());
      },
    );
  }

  Text _aNote(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Время намаза рассчитано согласно PrayTimes.org с уточнениями ',
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Духовного управления мусульман Казахстана',
            style: TextStyle(color: Theme.of(context).primaryColor),
            recognizer: _muftiyatTapRecognizer,
          ),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _setFontScalerColor(double value) {
    if (value == fontsScaleDefault) {
      _fontScaleColor = Color(primaryColor);
      _fontScaleLabel = 'По умолчанию';
    } else {
      _fontScaleLabel = null;
      if (value < fontsScaleDefault)
        _fontScaleColor = Colors.green[400]!;
      else
        _fontScaleColor = Colors.red[400]!;
    }
  }

  void _setAzanVolumeLabel(double value) {
    if (value == azanVolumeDefault) {
      _azanVolumeLabel = 'По умолчанию';
    } else {
      _azanVolumeLabel = null;
    }
  }

  Form _form(SettingsSuccess state) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TypeAheadField(
            controller: _cityNameController,
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(labelText: 'Город'),
                validator: (value) {
                  if (value!.isEmpty) {
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
              );
            },
            onSelected: (value) => _cityNameController.text = value,
            itemBuilder: (_, value) => ListTile(title: Text(value)),
            suggestionsCallback: (pattern) => _filterCities(pattern, state),
            emptyBuilder: (context) => ListTile(title: Text('Не найдено')),
          ),
          SizedBox(height: 17),
          if (state is SettingsCitySelectInProgress)
            CircularProgressIndicator()
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    child: Text('СОХРАНИТЬ ГОРОД'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final city = state.cities.firstWhere((element) =>
                            element.title.toLowerCase() ==
                            _selectedCity?.toLowerCase());

                        context.read<SettingsBloc>().add(
                              SettingsCitySelected(
                                city,
                                state.cities,
                                state.fontsScale,
                                state.azanVolume,
                                state.requestHidjraDateFromServer,
                              ),
                            );
                      }
                    },
                  ),
                ),
              ],
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
