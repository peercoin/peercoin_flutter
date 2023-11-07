import 'package:flutter/material.dart';
import 'package:peercoin/models/experimental_features.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';
import 'settings_helpers.dart';

class AppSettingsExperimentalFeaturesScreen extends StatefulWidget {
  const AppSettingsExperimentalFeaturesScreen({super.key});

  @override
  State<AppSettingsExperimentalFeaturesScreen> createState() =>
      _AppSettingsExperimentalFeaturesScreenState();
}

class _AppSettingsExperimentalFeaturesScreenState
    extends State<AppSettingsExperimentalFeaturesScreen> {
  bool _initial = true;

  late AppSettingsProvider _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettingsProvider>(context);

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void _saveFeature(String featureName, bool newState) async {
    final features = _settings.activatedExperimentalFeatures;
    if (newState == true) {
      features.add(featureName);
    } else {
      features.remove(featureName);
    }
    _settings.setActivatedExperimentalFeatures(features);

    saveSnack(context);
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
          AppLocalizations.instance.translate(
            'app_settings_experimental_features',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: ExperimentalFeatures.values
                  .map(
                    (e) => SwitchListTile(
                      title: Text(
                        AppLocalizations.instance.translate(
                          'app_settings_experimental_feature_${e.name}',
                        ),
                      ),
                      value: _settings.activatedExperimentalFeatures
                          .contains(e.name),
                      onChanged: (newState) {
                        _saveFeature(e.name, newState);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
