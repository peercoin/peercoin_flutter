import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class ROASTWalletDashboardScreen extends StatefulWidget {
  const ROASTWalletDashboardScreen({super.key});

  @override
  State<ROASTWalletDashboardScreen> createState() =>
      _ROASTWalletDashboardScreenState();
}

class _ROASTWalletDashboardScreenState
    extends State<ROASTWalletDashboardScreen> {
  bool _initial = true;
  DateTime _lastUpdate = DateTime.now();
  late Client _roastClient;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROAST Wallet Dashboard'), // TODO i18n
      ),
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
