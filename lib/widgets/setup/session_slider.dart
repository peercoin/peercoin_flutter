import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peercoin/tools/logger_wrapper.dart';

class SetupSessionSlider extends StatefulWidget {
  const SetupSessionSlider({Key? key}) : super(key: key);

  @override
  State<SetupSessionSlider> createState() => _SetupSessionSliderState();
}

class _SetupSessionSliderState extends State<SetupSessionSlider> {
  double _currentSliderValue = 3;
  final List<double> _availableSliderValues = [1, 7, 14, 30, 90, 180, 360];

  void _storeSelectedSessionLength() async {
    final sessionLength =
        _availableSliderValues[_currentSliderValue.toInt()].round().toString();

    await FlutterSecureStorage()
        .write(key: 'sessionLength', value: sessionLength);

    LoggerWrapper.logInfo(
      'SetupSessionSlider',
      '_storeSelectedSessionLength',
      '$sessionLength stored',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Colors.white,
      inactiveColor: Theme.of(context).shadowColor,
      value: _currentSliderValue,
      min: 0,
      max: _availableSliderValues.length - 1,
      divisions: _availableSliderValues.length - 1,
      onChangeEnd: (_) => _storeSelectedSessionLength(),
      label: _availableSliderValues[_currentSliderValue.toInt()]
          .round()
          .toString(),
      onChanged: (value) {
        setState(() {
          _currentSliderValue = value;
        });
      },
    );
  }
}
