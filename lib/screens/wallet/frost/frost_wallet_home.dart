import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/screens/wallet/standard_and_watch_only_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/wallet/frost_group/landing_configured.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/wallet_home/wallet_delete_watch_only_bottom_sheet.dart';
import 'package:provider/provider.dart';

class FrostWalletHomeScreen extends StatefulWidget {
  const FrostWalletHomeScreen({super.key});

  @override
  State<FrostWalletHomeScreen> createState() => _FrostWalletHomeScreenState();
}

class _FrostWalletHomeScreenState extends State<FrostWalletHomeScreen> {
  bool _initial = true;
  late CoinWallet _wallet;
  late FrostGroup _frostGroup;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _wallet = arguments['wallet'];

      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      _frostGroup = await walletProvider.getFrostGroup(_wallet.name);

      setState(() {
        _initial = false;
      });

      if (mounted) {
        context.loaderOverlay.hide();
      }
    }

    super.didChangeDependencies();
  }

  void _triggerDeleteFrostGroupBottomSheet({
    required BuildContext context,
    required WalletProvider walletProvider,
    required CoinWallet wallet,
  }) async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return WalletDeleteWatchOnlyBottomSheet(
          action: () async {
            await walletProvider.deleteFROSTWallet(_wallet.name);
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
      },
      context: context,
    );
  }

  void _selectPopUpMenuItem(String value) {
    switch (value) {
      case 'change_title':
        titleEditDialog(context, _wallet);
        break;
      case 'delete_frost_group':
        _triggerDeleteFrostGroupBottomSheet(
          context: context,
          walletProvider: Provider.of<WalletProvider>(context, listen: false),
          wallet: _wallet,
        );
        break;
      default:
    }
  }

  List<Widget> _calcPopupMenuItems(BuildContext context) {
    return [
      PopupMenuButton(
        onSelected: (dynamic value) => _selectPopUpMenuItem(value),
        itemBuilder: (_) {
          return [
            PopupMenuItem(
              value: 'change_title',
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'wallet_pop_menu_change_title',
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'delete_frost_group',
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'delete_wallet',
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(_wallet.title),
        actions: _calcPopupMenuItems(context),
      ),
      body: _initial
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _frostGroup.isCompleted
              ? const FrostGroupLandingConfigured()
              : FrostGroupSetupLanding(
                  frostGroup: _frostGroup,
                ),
    );
  }
}
