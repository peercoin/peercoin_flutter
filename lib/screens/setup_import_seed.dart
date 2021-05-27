import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/setup_progress.dart';
import 'package:provider/provider.dart';

class SetupImportSeedScreen extends StatefulWidget {
  @override
  _SetupImportSeedState createState() => _SetupImportSeedState();
}

class _SetupImportSeedState extends State<SetupImportSeedScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void createWallet(context) async {
    setState(() {
      _loading = true;
    });
    var _activeWallets = Provider.of<ActiveWallets>(context, listen: false);
    try {
      await _activeWallets.init();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('setup_securebox_fail')!,
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 10),
      ));
    }
    await _activeWallets.createPhrase(_controller.text);
    var prefs =
        await Provider.of<UnencryptedOptions>(context, listen: false).prefs;
    await prefs.setBool('importedSeed', true);
    await Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.SetUpPin, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupProgressIndicator(2),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).primaryColor,
          height: MediaQuery.of(context).size.height,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/icon/ppc-icon-white-256.png',
                  width: 50,
                ),
                Text(
                  AppLocalizations.instance.translate('setup_import_title')!,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'setup_import_note',
                    )!,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        controller: _controller,
                        validator: (value) {
                          if (value!.split(' ').length < 12) {
                            return AppLocalizations.instance.translate(
                              'import_seed_error_1',
                            );
                          }
                          if (bip39.validateMnemonic(value) == false) {
                            return AppLocalizations.instance.translate(
                              'import_seed_error_2',
                            );
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              var data = await Clipboard.getData('text/plain');
                              if (data != null) {
                                _controller.text = data.text!;
                              }
                              FocusScope.of(context).unfocus(); //hide keyboard
                            },
                            icon: Icon(Icons.paste,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 5,
                      ),
                    ),
                  ),
                ),
                _loading
                    ? LoadingIndicator()
                    : ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            createWallet(context);
                          }
                        },
                        icon: Icon(Icons.input),
                        label: Text(AppLocalizations.instance.translate(
                          'import_seed_button',
                        )!)),
              ]),
        ),
      ),
    );
  }
}
