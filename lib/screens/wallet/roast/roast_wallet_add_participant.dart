import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/models/hive/roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/service_container.dart';

class ParticpantNavigatorPopDTO {
  final Identifier identifier;
  final ECCompressedPublicKey key;

  ParticpantNavigatorPopDTO({
    required this.identifier,
    required this.key,
  });
}

class ROASTWalletAddParticipantScreen extends StatefulWidget {
  const ROASTWalletAddParticipantScreen({super.key});

  @override
  State<ROASTWalletAddParticipantScreen> createState() =>
      _ROASTWalletAddParticipantScreenState();
}

enum ParticipantType { id, name }

class _ROASTWalletAddParticipantScreenState
    extends State<ROASTWalletAddParticipantScreen> {
  bool _initial = true;
  ParticipantType _type = ParticipantType.name;
  late ROASTClient _roastClient;
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();
  final _ecPubKeyKey = GlobalKey<FormFieldState>();
  final _ecPubKeyController = TextEditingController();

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _roastClient = arguments['roastClient'];
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void _save() {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final id = _type == ParticipantType.id
          ? Identifier.fromHex(_nameController.text)
          : Identifier.fromString(_nameController.text);

      // persist name
      _roastClient.participantNames[id.toString()] = _nameController.text;

      Navigator.of(context).pop(
        ParticpantNavigatorPopDTO(
          identifier: id,
          key: ECCompressedPublicKey.fromHex(_ecPubKeyController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('roast_setup_group_member_add'),
          ),
        ),
        actions: [
          Padding(
            key: const Key('saveServerButton'),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () => _save(),
              icon: const Icon(Icons.save),
            ),
          ),
        ],
      ),
      body: Align(
        child: PeerContainer(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.instance
                        .translate('roast_setup_group_member_add_description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    key: _nameKey,
                    autocorrect: false,
                    controller: _nameController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      labelText: AppLocalizations.instance.translate(
                        _type == ParticipantType.name
                            ? 'roast_setup_group_member_name_input'
                            : 'roast_setup_group_member_id_input',
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          var data = await Clipboard.getData('text/plain');
                          _nameController.text = data!.text!.trim();
                        },
                        icon: Icon(
                          Icons.paste_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    maxLines: null,
                    onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.instance.translate(
                          'roast_setup_group_member_input_name_empty_error',
                        );
                      } else if (_type == ParticipantType.id) {
                        try {
                          // try to convert input value to Identifier
                          Identifier.fromHex(_nameController.text);
                        } catch (e) {
                          return AppLocalizations.instance.translate(
                            'roast_setup_group_member_input_name_invalid_error',
                          );
                        }
                      }
                      return null;
                    },
                  ),
                  Text(
                    AppLocalizations.instance.translate(
                      'roast_setup_group_member_name_input_hint',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.instance.translate(
                        'roast_setup_group_member_switch_id_name_hint',
                      ),
                    ),
                    value: _type == ParticipantType.id,
                    onChanged: (newState) {
                      setState(() {
                        _type = newState
                            ? ParticipantType.id
                            : ParticipantType.name;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    key: _ecPubKeyKey,
                    autocorrect: false,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.key),
                      labelText: AppLocalizations.instance
                          .translate('roast_setup_group_member_pub_key_input'),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          var data = await Clipboard.getData('text/plain');
                          _ecPubKeyController.text = data!.text!.trim();
                        },
                        icon: Icon(
                          Icons.paste_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    minLines: 4,
                    maxLines: 4,
                    controller: _ecPubKeyController,
                    onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                    validator: (value) {
                      try {
                        // try to convert input value to ECPublicKey
                        ECPublicKey.fromHex(
                          _ecPubKeyController.text,
                        );
                      } catch (e) {
                        return AppLocalizations.instance.translate(
                          'roast_setup_group_member_input_error',
                        );
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO scan QR code
