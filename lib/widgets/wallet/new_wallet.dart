import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';

class NewWalletDialog extends StatefulWidget {
  const NewWalletDialog({super.key});

  @override
  State<NewWalletDialog> createState() => _NewWalletDialogState();
}

Map<String, Coin> _availableCoins = AvailableCoins.availableCoins;

class _NewWalletDialogState extends State<NewWalletDialog> {
  String _coin = '';
  bool _initial = true;
  bool _watchOnly = false;
  late AppSettingsProvider _appSettings;

  Future<void> addWallet({
    required bool isROAST,
    required bool isTestnet,
  }) async {
    try {
      final appSettings = context.read<AppSettingsProvider>();
      final navigator = Navigator.of(context);
      final WalletProvider walletProvider = context.read<WalletProvider>();
      final letterCode = _availableCoins[_coin]!.letterCode;
      final nOfWalletOfLetterCode = walletProvider.availableWalletValues
          .where((element) => element.letterCode == letterCode)
          .length;
      final nOfWalletOfLetterCodeROAST = walletProvider.availableWalletValues
          .where(
            (element) => element.letterCode == letterCode && element.isROAST,
          )
          .length;

      // If this is a ROAST wallet, prompt for key generation options
      int? reusedIndexForROAST;
      if (isROAST) {
        final keyGenerationChoice = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.instance.translate(
                  'roast_key_generation_title',
                ),
              ),
              content: Text(
                AppLocalizations.instance.translate(
                  'roast_key_generation_prompt',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'roast_generate_new_key',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'roast_reuse_existing_key',
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // If dialog was dismissed or user chose to reuse key
        if (keyGenerationChoice == false) {
          // Show dialog to input HD index
          final TextEditingController indexController = TextEditingController();
          final formKey = GlobalKey<FormState>();

          if (!mounted) return;
          final hdIndex = await showDialog<int>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalizations.instance.translate(
                    'roast_hd_index_title',
                  ),
                ),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: indexController,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.instance.translate(
                        'roast_hd_index_label',
                      ),
                      hintText: AppLocalizations.instance.translate(
                        'roast_hd_index_hint',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.instance.translate(
                          'roast_hd_index_empty_error',
                        );
                      }
                      int? index = int.tryParse(value);
                      if (index == null) {
                        return AppLocalizations.instance.translate(
                          'roast_hd_index_invalid_error',
                        );
                      }
                      if (index < 0) {
                        return AppLocalizations.instance.translate(
                          'roast_hd_index_range_error',
                        );
                      }
                      return null;
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.instance.translate('cancel'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(context).pop(
                          int.parse(indexController.text),
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.instance.translate('confirm'),
                    ),
                  ),
                ],
              );
            },
          );

          // If user cancelled HD index dialog, cancel wallet creation
          if (hdIndex == null) {
            return;
          }

          reusedIndexForROAST = hdIndex;
        }
        // If user cancelled the first dialog, abort wallet creation
        else if (keyGenerationChoice == null) {
          return;
        }
        // If keyGenerationChoice is true, we'll generate a new key (reusedIndexForROAST remains null)
      }

      // generate identifier
      final walletName = isROAST
          ? '${_coin}_roast_group_$nOfWalletOfLetterCodeROAST'
          : '${_coin}_$nOfWalletOfLetterCode';

      // generate title
      String title = _availableCoins[_coin]!.displayName;
      if (nOfWalletOfLetterCode > 0) {
        title = '$title ${nOfWalletOfLetterCode + 1}';
      }
      if (isROAST) {
        title =
            'ROAST Group ${nOfWalletOfLetterCodeROAST == 0 ? "" : nOfWalletOfLetterCodeROAST + 1}';
        if (isTestnet) {
          title = 'Test $title';
        }
      }

      final prefs = await SharedPreferences.getInstance();

      await walletProvider.addWallet(
        name: walletName,
        title: title,
        letterCode: letterCode,
        isImportedSeed: prefs.getBool('importedSeed') == true,
        watchOnly: _watchOnly,
        isROAST: isROAST,
        reusedIndexForROAST: reusedIndexForROAST,
      );

      //add to order list
      _appSettings.setWalletOrder(_appSettings.walletOrder..add(walletName));

      //enable notifications
      final notificationList = appSettings.notificationActiveWallets;
      notificationList.add(walletName);
      appSettings.setNotificationActiveWallets(notificationList);

      navigator.pop();
    } catch (e) {
      LoggerWrapper.logError(
        'NewWalletScreen',
        'addWallet',
        'Error adding wallet: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _coin == ''
                  ? AppLocalizations.instance.translate('select_coin')
                  : AppLocalizations.instance.translate('add_coin_failed'),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _appSettings = context.read<AppSettingsProvider>();
      if (_appSettings.authenticationOptions!['newWallet']!) {
        await Auth.requireAuth(
          context: context,
          biometricsAllowed: _appSettings.biometricsAllowed,
          canCancel: false,
        );
      }

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    final actualAvailableWallets = _availableCoins.keys;

    if (actualAvailableWallets.isNotEmpty) {
      for (final wallet in actualAvailableWallets) {
        bool isTestnet = _availableCoins[wallet]!.letterCode == 'tPPC';
        list.add(
          SimpleDialogOption(
            onPressed: () {
              _coin = wallet;
              addWallet(isROAST: false, isTestnet: isTestnet);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  AvailableCoins.getSpecificCoin(_availableCoins[wallet]!.name)
                      .iconPath,
                  width: 16,
                ),
              ),
              title: Text(_availableCoins[wallet]!.displayName),
            ),
          ),
        );
        // inject ROAST
        if (_appSettings.activatedExperimentalFeatures.contains('roast') &&
            _watchOnly == false) {
          list.add(
            SimpleDialogOption(
              onPressed: () {
                _coin = wallet;
                addWallet(isROAST: true, isTestnet: isTestnet);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    AvailableCoins.getROASTIconPath(wallet),
                    width: 16,
                  ),
                ),
                title: Text(
                  '${isTestnet ? "Testnet " : ""}ROAST Group',
                ),
              ),
            ),
          );
        }
      }
    } else {
      list.add(
        Center(
          child: Text(
            AppLocalizations.instance.translate('no_new_wallet'),
          ),
        ),
      );
    }
    list.add(
      SimpleDialogOption(
        child: GestureDetector(
          onTap: () => setState(() {
            _watchOnly = !_watchOnly;
          }),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _watchOnly,
                onChanged: (e) => setState(() {
                  _watchOnly = e!;
                }),
              ),
              Text(AppLocalizations.instance.translate('watch_only')),
            ],
          ),
        ),
      ),
    );

    return SimpleDialog(
      title: Text(AppLocalizations.instance.translate('add_new_wallet')),
      children: list,
    );
  }
}
