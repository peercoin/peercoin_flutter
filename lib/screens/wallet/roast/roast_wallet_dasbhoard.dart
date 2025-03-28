import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class ROASTWalletDashboardScreen extends StatefulWidget {
  const ROASTWalletDashboardScreen({super.key});

  @override
  State<ROASTWalletDashboardScreen> createState() =>
      _ROASTWalletDashboardScreenState();
}

enum ROASTWalletTab {
  rejectedRequests,
  openRequests,
  completeDKGs,
  newDKG,
}

class _ROASTWalletDashboardScreenState
    extends State<ROASTWalletDashboardScreen> {
  bool _initial = true;
  DateTime _lastUpdate = DateTime.now();
  late Client _roastClient;
  ROASTWalletTab _selectedTab = ROASTWalletTab.openRequests;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _roastClient = arguments['roastClient'];

      _roastClient.events.listen((event) {
        print('Event: $event');
        print(_roastClient.signaturesRequests);
        print('requests:');
        print(_roastClient.dkgRequests);
        print('accepted:');
        print(_roastClient.acceptedDkgs);
        print('keys:');
        print(_roastClient.keys);

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
          icon: const Icon(Icons.download_rounded),
          label:
              AppLocalizations.instance.translate('wallet_bottom_nav_receive'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_rounded),
          tooltip: 'Transactions',
          label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          tooltip: 'Address Book',
          icon: const Icon(Icons.menu_book_rounded),
          label: AppLocalizations.instance.translate('wallet_bottom_nav_addr'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.upload_rounded),
          label: AppLocalizations.instance.translate('wallet_bottom_nav_send'),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                child: PeerContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PeerButton(
                        text: 'Request DKG',
                        action: () async {
                          await _roastClient.requestDkg(
                            NewDkgDetails(
                              name: 'test${DateTime.now()}',
                              description: 'test',
                              threshold: 2,
                              expiry: Expiry(const Duration(days: 1)),
                            ),
                          );
                          setState(() {
                            _lastUpdate = DateTime.now();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Signatures Requests'), // TODO i18n
                      ..._roastClient.dkgRequests.map((request) {
                        return Column(
                          children: [
                            Text(
                              request.completed.length <
                                      request.details.threshold
                                  ? 'Pending'
                                  : 'Completed',
                            ),
                            Text('Name: ${request.details.name}'),
                            Text(
                              'Description: ${request.details.description}',
                            ),
                            Text('Threshold: ${request.details.threshold}'),
                            PeerButton(
                              text: 'Ack',
                              action: () async {
                                await _roastClient
                                    .acceptDkg(request.details.name);
                              },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),
                      const Text('Signatures Accepted'), // TODO i18n
                      ..._roastClient.acceptedDkgs.map((accepted) {
                        return Column(
                          children: [
                            Text('Name: ${accepted.details.name}'),
                            Text(
                                'Description: ${accepted.details.description}'),
                            Text('Threshold: ${accepted.details.threshold}'),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(_lastUpdate.toIso8601String())
        ],
      ),
    );
  }
}

// TODO logout button
