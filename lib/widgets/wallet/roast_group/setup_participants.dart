import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_add_participant.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants_finger_print_bottom_sheet.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants_share_pubkey_bottom_sheet.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_pubkey_remove_participant_bottom_sheet.dart';
import 'package:peercoin/tools/roast_config_export.dart';
import 'package:peercoin/exceptions/roast_config_exceptions.dart';

class ROASTGroupSetupParticipants extends StatefulWidget {
  final Function changeStep;
  final ROASTWallet roastWallet;
  final CoinWallet coinWallet;
  final Map<Identifier, ECCompressedPublicKey>? importedParticipants;

  const ROASTGroupSetupParticipants({
    required this.changeStep,
    required this.roastWallet,
    required this.coinWallet,
    this.importedParticipants,
    super.key,
  });

  @override
  State<ROASTGroupSetupParticipants> createState() =>
      _ROASTGroupSetupParticipantsState();
}

class _ROASTGroupSetupParticipantsState
    extends State<ROASTGroupSetupParticipants> {
  bool _initial = true;
  bool _isExporting = false;
  final Map<Identifier, ECCompressedPublicKey> _participants = {};

  @override
  void didChangeDependencies() {
    if (_initial) {
      if (widget.roastWallet.clientConfig != null) {
        // finalized group
        _participants
            .addAll(widget.roastWallet.clientConfig!.group.participants);
      } else if (widget.importedParticipants != null) {
        // imported group configuration
        _participants.addAll(widget.importedParticipants!);
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
      arguments: RoastWalletHomeScreenArguments(coinWallet: widget.coinWallet),
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
      context: context,
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
    );
  }

  Widget _buildImportValidationStatus() {
    if (widget.importedParticipants == null) return const SizedBox.shrink();

    final participantCount = _participants.length;
    final isValidForROAST = participantCount >= 2;
    final hasOurself = _participants.keys.any((id) => 
        widget.roastWallet.participantNames[id.toString()] == widget.roastWallet.ourName);
    
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.instance.translate('roast_import_validation_status'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildValidationItem(
            icon: participantCount >= 2 ? Icons.check_circle : Icons.warning,
            color: participantCount >= 2 ? Colors.green : Colors.orange,
            text: AppLocalizations.instance.translate('roast_import_validation_min_participants')
                .replaceAll('%count%', participantCount.toString())
                .replaceAll('%min%', '2'),
          ),
          const SizedBox(height: 4),
          _buildValidationItem(
            icon: hasOurself ? Icons.check_circle : Icons.info,
            color: hasOurself ? Colors.green : Colors.blue,
            text: hasOurself 
                ? AppLocalizations.instance.translate('roast_import_validation_includes_you')
                : AppLocalizations.instance.translate('roast_import_validation_add_yourself'),
          ),
          const SizedBox(height: 4),
          _buildValidationItem(
            icon: isValidForROAST ? Icons.check_circle : Icons.warning,
            color: isValidForROAST ? Colors.green : Colors.orange,
            text: isValidForROAST
                ? AppLocalizations.instance.translate('roast_import_validation_ready')
                : AppLocalizations.instance.translate('roast_import_validation_not_ready'),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportConfiguration() async {
    if (_isExporting) return;
    
    // Show confirmation dialog with export preview
    final bool? shouldExport = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final preview = ROASTConfigExport.getExportPreview(
          widget.roastWallet,
          _participants,
        );
        
        return AlertDialog(
          title: Text(AppLocalizations.instance.translate('roast_export_confirm_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.instance.translate('roast_export_confirm_description')),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.instance.translate('roast_export_preview_title'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${AppLocalizations.instance.translate('roast_export_preview_participants')}: ${preview['participantCount']}'),
              Text('${AppLocalizations.instance.translate('roast_export_preview_filename')}: ${preview['filename']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.instance.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.instance.translate('roast_export_confirm_button')),
            ),
          ],
        );
      },
    );

    if (shouldExport != true) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      // Export the configuration
      final filePath = await ROASTConfigExport.exportGroupConfiguration(
        widget.roastWallet,
        _participants,
      );
      
      // Share the exported file
      await ROASTConfigExport.shareExportedFile(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.instance.translate('roast_export_success')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = AppLocalizations.instance.translate('roast_export_error');
        if (e is ROASTConfigException) {
          errorMessage = e.message;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
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
                    if (widget.importedParticipants != null) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.instance.translate('roast_import_config_loaded'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.instance.translate('roast_import_participant_count')
                                        .replaceAll('%count%', _participants.length.toString()),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    _buildImportValidationStatus(),
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
                                  color: Theme.of(context).colorScheme.tertiary,
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
                                              .tertiary,
                                        ),
                                      ),
                            tileColor: Theme.of(context).colorScheme.primary,
                            title: Text(
                              participantName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            subtitle: Text(
                              ecPubkey,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.tertiary,
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
                      height: 10,
                    ),
                    PeerButton(
                      text: _isExporting 
                          ? AppLocalizations.instance.translate('roast_export_exporting')
                          : AppLocalizations.instance.translate('roast_export_button'),
                      disabled: _participants.length < 2 || _isExporting,
                      action: () => _exportConfiguration(),
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
