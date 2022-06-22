import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class SetupSessionSlider extends StatefulWidget {
  const SetupSessionSlider({Key? key}) : super(key: key);

  @override
  State<SetupSessionSlider> createState() => _SetupSessionSliderState();
}

class _SetupSessionSliderState extends State<SetupSessionSlider> {
  double _currentSliderValue = 3;
  final List<double> _availableSliderValues = [1, 7, 14, 30, 90, 180, 360];

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Colors.white,
      inactiveColor: Theme.of(context).shadowColor,
      value: _currentSliderValue,
      min: 0,
      max: _availableSliderValues.length - 1,
      divisions: _availableSliderValues.length - 1,
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
