import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_add_participant.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants_finger_print_bottom_sheet.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants_share_pubkey_bottom_sheet.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_pubkey_remove_participant_bottom_sheet.dart';

class ROASTGroupSetupParticipants extends StatefulWidget {
  final Function changeStep;
  final ROASTWallet roastWallet;

  const ROASTGroupSetupParticipants({
    required this.changeStep,
    required this.roastWallet,
    super.key,
  });

  @override
  State<ROASTGroupSetupParticipants> createState() =>
      _ROASTGroupSetupParticipantsState();
}

class _ROASTGroupSetupParticipantsState
    extends State<ROASTGroupSetupParticipants> {
  bool _initial = true;
  final Map<Identifier, ECCompressedPublicKey> _participants = {};

  @override
  void didChangeDependencies() {
    if (_initial) {
      if (widget.roastWallet.clientConfig != null) {
        // finalized group
        _participants
            .addAll(widget.roastWallet.clientConfig!.group.participants);
      } else {
        // add self to uncompleted group
        final id = Identifier.fromSeed(widget.roastWallet.ourName);
        _participants[id] =
            ECCompressedPublicKey.fromPubkey(widget.roastWallet.ourKey.pubkey);
        widget.roastWallet.participantNames[id.toString()] =
            widget.roastWallet.ourName;
      }

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _triggerRemoveParticipantBottomSheet(
    String participantName,
    String participantPubKey,
  ) async {
    LoggerWrapper.logInfo(
      'ROASTGroupSetupParticipants',
      '_triggerRemoveParticipantBottomSheet',
      'participant $participantName delete bottom sheet opened',
    );

    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupPubkeyRemoveParticipantBottomSheet(
          participantName: participantName,
          action: () => _removeParticipant(participantPubKey),
        );
      },
      context: context,
    );
  }

  void _addParticipant() async {
    final res = await Navigator.of(context).pushNamed(
      Routes.roastWalletAddParticipant,
      arguments: {
        'roastWallet': widget.roastWallet,
        'participants': _participants,
      },
    );
    if (res.runtimeType != ParticpantNavigatorPopDTO) {
      return;
    }
    final dto = res as ParticpantNavigatorPopDTO;

    LoggerWrapper.logInfo(
      'ROASTGroupSetupParticipants',
      '_addParticipant',
      'participant added',
    );
    setState(() {
      _participants[dto.identifier] = dto.key;
    });
  }

  void _removeParticipant(String participantPubKey) {
    Navigator.of(context).pop();

    // remove participant from group
    widget.roastWallet.clientConfig!.group.participants
        .removeWhere((key, value) => value.hex == participantPubKey);

    setState(() {
      // remove copy of participant from local state
      _participants.removeWhere((key, value) => value.hex == participantPubKey);
    });
    LoggerWrapper.logInfo(
      'ROASTGroupSetupParticipants',
      '_removeParticipant',
      'participant removed',
    );
  }

  void _completeROASTClient() {
    widget.roastWallet.isCompleted = true;
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(
      Routes.roastWalletHome,
      arguments: {
        'roastWallet': widget.roastWallet,
        'isCompleted': true,
      },
    );
  }

  void _showFingerprint() async {
    // save group
    widget.roastWallet.clientConfig = ClientConfig(
      id: Identifier.fromSeed(widget.roastWallet.ourName),
      group: GroupConfig(
        id: widget.roastWallet.groupId,
        participants: _participants,
      ),
    );

    final fingerPrint =
        bytesToHex(widget.roastWallet.clientConfig!.group.fingerprint);
    LoggerWrapper.logInfo(
      'ROASTGroupSetupParticipants',
      '_showFingerprint',
      fingerPrint,
    );

    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupParticipantsFingerPrintBottomSheet(
          fingerPrint: fingerPrint,
          action: () => _completeROASTClient(),
        );
      },
      context: context,
    );
  }

  void _sharePubKey() async {
    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupParticipantsSharePubKeyBottomSheet(
          pubKey: widget.roastWallet.ourKey.pubkey.hex,
          ourName: widget.roastWallet.ourName,
          action: () => _completeROASTClient(),
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.changeStep(ROASTSetupStep.group);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        Text(
                          AppLocalizations.instance
                              .translate('roast_setup_group_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('roast_setup_group_description'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('roast_setup_group_hint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: _participants.entries.map((entry) {
                        String participantName = widget.roastWallet
                                .participantNames[entry.key.toString()] ??
                            '';
                        String ecPubkey = entry.value.hex;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ],
                            ),
                            trailing:
                                participantName == widget.roastWallet.ourName
                                    ? const SizedBox()
                                    : IconButton(
                                        onPressed: () =>
                                            _triggerRemoveParticipantBottomSheet(
                                          participantName,
                                          ecPubkey,
                                        ),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                            tileColor: Theme.of(context).colorScheme.primary,
                            title: Text(
                              participantName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            subtitle: Text(
                              ecPubkey,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'roast_setup_group_member_add',
                      ),
                      action: () => _addParticipant(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'roast_setup_group_cta',
                      ),
                      disabled: _participants.length < 2,
                      action: () => _showFingerprint(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'roast_setup_share_public_key_cta',
                      ),
                      action: () => _sharePubKey(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO add member: scan QR code
