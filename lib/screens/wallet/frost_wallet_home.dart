import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FrostWalletHomeScreen extends StatefulWidget {
  const FrostWalletHomeScreen({super.key});

  @override
  State<FrostWalletHomeScreen> createState() => _FrostWalletHomeScreenState();
}

class _FrostWalletHomeScreenState extends State<FrostWalletHomeScreen> {
  bool _initial = true;

  @override
  void didChangeDependencies() {
    if (_initial) {
      context.loaderOverlay.hide();
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
