import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/completed_keys_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/open_request_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/request_dkg_tab.dart';

class ROASTWalletDashboardScreen extends StatefulWidget {
  const ROASTWalletDashboardScreen({super.key});

  @override
  State<ROASTWalletDashboardScreen> createState() =>
      _ROASTWalletDashboardScreenState();
}

enum ROASTWalletTab {
  rejectedRequests,
  openRequests,
  generatedKeys,
  newDKG,
}

class _ROASTWalletDashboardScreenState
    extends State<ROASTWalletDashboardScreen> {
  bool _initial = true;
  late Client _roastClient;
  DateTime _lastUpdate = DateTime.now();
  ROASTWalletTab _selectedTab = ROASTWalletTab.openRequests;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _roastClient = arguments['roastClient'];

      _roastClient.events.listen((event) {
        LoggerWrapper.logInfo(
          'ROASTWalletDashboardScreen',
          'eventStream',
          event.toString(),
        );

        setState(() {
          _lastUpdate = DateTime.now();
        });
      });

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _roastClient.logout();
    super.dispose();
  }

  void changeTab(ROASTWalletTab t, [String? addr, String? lab]) {
    setState(() {
      _selectedTab = t;
    });
  }

  Widget _calcBody() {
    Widget body;
    switch (_selectedTab) {
      case ROASTWalletTab.rejectedRequests:
        body = const Expanded(
          child: SizedBox(),
        );
        break;
      case ROASTWalletTab.openRequests:
        body = Expanded(
          child: OpenRequestTab(
            roastClient: _roastClient,
            forceRender: () {
              setState(() {
                _lastUpdate = DateTime.now();
              });
            },
          ),
        );
        break;
      case ROASTWalletTab.generatedKeys:
        body = Expanded(
          child: CompletedKeysTab(
            roastClient: _roastClient,
          ),
        );
        break;
      case ROASTWalletTab.newDKG:
        body = Expanded(
          child: RequestDKGTab(
            roastClient: _roastClient,
          ),
        );
        break;
    }
    return body;
  }

  BottomNavigationBar _calcBottomNavBar(BuildContext context) {
    final bgColor = Theme.of(context).primaryColor;
    return BottomNavigationBar(
      unselectedItemColor: Theme.of(context).disabledColor,
      selectedItemColor: Colors.white,
      onTap: (index) {
        changeTab(ROASTWalletTab.values[index]);
      },
      currentIndex: _selectedTab.index,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.do_not_disturb),
          tooltip: 'Rejected DKGs',
          label: AppLocalizations.instance
              .translate('roast_wallet_bottom_nav_reject'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_rounded),
          tooltip: 'Requested DKGs',
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_open'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.key),
          tooltip: 'Generated Keys',
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_keys'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.note_add),
          tooltip: 'Request new DKG',
          label: AppLocalizations.instance.translate('roast_wallet_bottom_new'),
          backgroundColor: bgColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROAST Wallet Dashboard'), // TODO i18n
      ),
      bottomNavigationBar: _calcBottomNavBar(context),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          key: Key(_lastUpdate.toString()),
          children: [
            _calcBody(),
          ],
        ),
      ),
      // body: Column(
      //   children: [
      //     Expanded(
      //       child: SingleChildScrollView(
      //         child: Align(
      //           child: PeerContainer(
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //               children: [
      //
      //                 const SizedBox(height: 20),
      //                 const Text('Signatures Accepted'), // TODO i18n
      //                 ..._roastClient.acceptedDkgs.map((accepted) {
      //                   return Column(
      //                     children: [
      //                       Text('Name: ${accepted.details.name}'),
      //                       Text(
      //                           'Description: ${accepted.details.description}'),
      //                       Text('Threshold: ${accepted.details.threshold}'),
      //                     ],
      //                   );
      //                 }),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Text(_lastUpdate.toIso8601String())
      //   ],
      // ),
    );
  }
}

// TODO logout button
