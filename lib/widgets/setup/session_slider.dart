import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../tools/app_localizations.dart';
import '../../tools/logger_wrapper.dart';

class SetupSessionSlider extends StatefulWidget {
  const SetupSessionSlider({Key? key}) : super(key: key);

  @override
  State<SetupSessionSlider> createState() => _SetupSessionSliderState();
}

class _SetupSessionSliderState extends State<SetupSessionSlider> {
  double _currentSliderValue = 3;
  final List<double> _availableSliderValues = [1, 7, 14, 30, 90, 180, 365];

  @override
  void initState() {
    _storeSelectedSessionLength();
    super.initState();
  }

  void _storeSelectedSessionLength() async {
    final expiryDate = DateTime.now()
        .add(
          Duration(
            days: int.parse(
              _convertSlideToString(),
            ),
          ),
        )
        .millisecondsSinceEpoch;
    await const FlutterSecureStorage().write(
      key: 'sessionExpiresAt',
      value: expiryDate.toString(),
    );

    LoggerWrapper.logInfo(
      'SetupSessionSlider',
      '_storeSelectedSessionLength',
      '${expiryDate.toString()} stored',
    );
  }

  String _convertSlideToString() {
    return _availableSliderValues[_currentSliderValue.toInt()]
        .round()
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.instance.translate('setup_auth_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Slider(
          activeColor: Colors.white,
          inactiveColor: Theme.of(context).shadowColor,
          value: _currentSliderValue,
          min: 0,
          max: _availableSliderValues.length - 1,
          divisions: _availableSliderValues.length - 1,
          onChangeEnd: (_) => _storeSelectedSessionLength(),
          label: _convertSlideToString(),
          onChanged: (value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
        ),
        Text(
          AppLocalizations.instance.translate(
            _currentSliderValue == 0
                ? 'setup_auth_subtitle_singular'
                : 'setup_auth_subtitle_plural',
            {
              'days': _convertSlideToString(),
            },
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          AppLocalizations.instance.translate('setup_auth_hint'),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
