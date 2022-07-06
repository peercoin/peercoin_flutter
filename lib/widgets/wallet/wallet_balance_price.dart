import 'dart:async';

import 'package:flutter/material.dart';

class WalletBalancePrice extends StatefulWidget {
  final Text valueInFiat;
  final Text fiatCoinValue;
  const WalletBalancePrice({
    Key? key,
    required this.valueInFiat,
    required this.fiatCoinValue,
  }) : super(key: key);

  @override
  State<WalletBalancePrice> createState() => _WalletBalancePriceState();
}

class _WalletBalancePriceState extends State<WalletBalancePrice> {
  late Widget _animatedWidget;
  bool _showFiatCoinValue = false;
  late Timer _timer;

  @override
  void initState() {
    _animatedWidget = _valueInFiatWidget();
    Future.delayed(const Duration(seconds: 1), _widgetIntervalGiver());

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        _widgetIntervalGiver();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _valueInFiatWidget() =>
      SizedBox(key: const Key('valueInFiat'), child: widget.valueInFiat);

  Widget _fiatCoinValueWidget() =>
      SizedBox(key: const Key('fiatCoinValue'), child: widget.fiatCoinValue);

  _widgetIntervalGiver() {
    setState(() {
      _animatedWidget =
          _showFiatCoinValue ? _valueInFiatWidget() : _fiatCoinValueWidget();
      _showFiatCoinValue = !_showFiatCoinValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _animatedWidget,
    );
  }
}
