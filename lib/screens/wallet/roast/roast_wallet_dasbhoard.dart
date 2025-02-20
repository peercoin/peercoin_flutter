import 'package:flutter/material.dart';
import 'package:frost_noosphere/frost_noosphere.dart';

class ROASTWalletDashboardScreen extends StatefulWidget {
  const ROASTWalletDashboardScreen({super.key});

  @override
  State<ROASTWalletDashboardScreen> createState() =>
      _ROASTWalletDashboardScreenState();
}

class _ROASTWalletDashboardScreenState
    extends State<ROASTWalletDashboardScreen> {
  bool _initial = true;
  late Client _roastClient;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _roastClient = arguments['roastClient'];

      _roastClient.events.listen((event) {
        print('Event: $event');
      });

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
