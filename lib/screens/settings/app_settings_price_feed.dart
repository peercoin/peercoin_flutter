import 'package:flutter/material.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';
import '../../widgets/settings/settings_price_ticker.dart';

class AppSettingsPriceFeedScreen extends StatefulWidget {
  const AppSettingsPriceFeedScreen({super.key});

  @override
  State<AppSettingsPriceFeedScreen> createState() =>
      _AppSettingsPriceFeedScreenState();
}

class _AppSettingsPriceFeedScreenState
    extends State<AppSettingsPriceFeedScreen> {
  bool _initial = true;
  late AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettings>(context);

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_initial == true) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_price_feed'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: [
                const SizedBox(height: 10),
                SettingsPriceTicker(
                  _settings,
                  saveSnack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
