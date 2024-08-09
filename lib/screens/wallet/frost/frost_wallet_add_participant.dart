import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/service_container.dart';

class FrostWalletAddParticipantScreen extends StatefulWidget {
  const FrostWalletAddParticipantScreen({super.key});

  @override
  State<FrostWalletAddParticipantScreen> createState() =>
      _FrostWalletAddParticipantScreenState();
}

class _FrostWalletAddParticipantScreenState
    extends State<FrostWalletAddParticipantScreen> {
  bool _initial = true;
  late FrostGroup _frostGroup;
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();
  final _ecPubKeyKey = GlobalKey<FormFieldState>();
  final _ecPubKeyController = TextEditingController();

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _frostGroup = arguments['frostGroup'];
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('frost_setup_group_member_add'),
          ),
        ),
        actions: [
          Padding(
            key: const Key('saveServerButton'),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  _frostGroup.clientConfig.participants[_nameController.text] =
                      ECPublicKey(
                    Uint8List.fromList(_ecPubKeyController.text.codeUnits),
                  );
                  Navigator.of(context).pop(true);
                }
              },
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
                        .translate('frost_setup_group_member_add_description'),
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
                      labelText: AppLocalizations.instance
                          .translate('frost_setup_group_member_name_input'),
                    ),
                    maxLines: null,
                    onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                    validator: (value) {
                      return null;
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
                          .translate('frost_setup_group_member_pub_key_input'),
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
                          'frost_setup_group_member_input_error',
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
