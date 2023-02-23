import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import 'setup_landing.dart';

class SetupImportSeedScreen extends StatefulWidget {
  const SetupImportSeedScreen({Key? key}) : super(key: key);

  @override
  State<SetupImportSeedScreen> createState() => _SetupImportSeedState();
}

class _SetupImportSeedState extends State<SetupImportSeedScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void createWallet(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    final activeWallets = context.read<ActiveWallets>();
    final navigator = Navigator.of(context);
    try {
      await activeWallets.init();
    } catch (e) {
      LoggerWrapper.logError(
        'SetupImportSeed',
        'createWallet',
        e.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('setup_securebox_fail'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    await activeWallets.createPhrase(_controller.text);
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('importedSeed', true);
    await navigator.pushNamed(Routes.setupAuth);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
      borderSide: BorderSide(
        width: 2,
        color: Colors.transparent,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupLandingScreen.calcContainerHeight(context),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const PeerProgress(step: 2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/img/setup-security.png',
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const PeerButtonSetupBack(),
                          AutoSizeText(
                            AppLocalizations.instance.translate(
                              'setup_import_title',
                            ),
                            maxFontSize: 28,
                            minFontSize: 25,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        width: MediaQuery.of(context).size.width > 1200
                            ? MediaQuery.of(context).size.width / 2
                            : MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.keyboard_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 40,
                                  ),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            1200
                                        ? MediaQuery.of(context).size.width /
                                            2.5
                                        : MediaQuery.of(context).size.width /
                                            1.9,
                                    child: Text(
                                      AppLocalizations.instance
                                          .translate('setup_import_note'),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.left,
                                      maxLines: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                color: Theme.of(context).colorScheme.background,
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  key: const Key('importTextField'),
                                  controller: _controller,
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value!.split(' ').length < 12) {
                                      return AppLocalizations.instance
                                          .translate(
                                        'import_seed_error_1',
                                      );
                                    }
                                    if (bip39.validateMnemonic(value) ==
                                        false) {
                                      return AppLocalizations.instance
                                          .translate(
                                        'import_seed_error_2',
                                      );
                                    }
                                    return null;
                                  },
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'e.g. mushrooms pepper courgette onion asparagus garlic sweetcorn nut pumpkin potato bean spinach',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 16,
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        final focusScope =
                                            FocusScope.of(context);
                                        var data = await Clipboard.getData(
                                          'text/plain',
                                        );
                                        if (data != null) {
                                          _controller.text = data.text!.trim();
                                        }
                                        focusScope.unfocus(); //hide keyboard
                                      },
                                      icon: Icon(
                                        Icons.paste,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    ),
                                    border: border,
                                    focusedBorder: border,
                                    enabledBorder: border,
                                    errorStyle: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    errorBorder: border,
                                    focusedErrorBorder: border,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  minLines: 5,
                                  maxLines: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PeerButtonSetupLoading(
                action: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    createWallet(context);
                  }
                },
                text: AppLocalizations.instance.translate(
                  'import_button',
                ),
                loading: _loading,
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
