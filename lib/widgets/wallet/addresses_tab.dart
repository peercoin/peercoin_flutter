import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/tools/validators.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../models/hive/wallet_address.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/connection_provider.dart';
import '../../screens/wallet/standard_and_watch_only_wallet_home.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../../tools/logger_wrapper.dart';
import '../double_tab_to_clipboard.dart';
import 'wallet_home/wallet_home_qr.dart';

class AddressTab extends StatefulWidget {
  final String walletName;
  final List<WalletAddress> walletAddresses;
  final Function changeTab;

  const AddressTab({
    required this.walletName,
    required this.walletAddresses,
    required this.changeTab,
    super.key,
  });

  @override
  State<AddressTab> createState() => _AddressTabState();
}

class _AddressTabState extends State<AddressTab> {
  bool _initial = true;
  List<WalletAddress> _filteredSend = [];
  List<WalletAddress> _filteredReceive = [];
  late Coin _availableCoin;
  final _formKey = GlobalKey<FormState>();
  final _searchKey = GlobalKey<FormFieldState>();
  final searchController = TextEditingController();
  bool _search = false;
  bool _showChangeAddresses = true;
  bool _optionsExpanded = false;
  bool _showLabel = true;
  bool _showUsed = true;
  bool _showEmpty = true;
  bool _showUnwatched = false;
  bool _showSendingAddresses = true;
  final Map _addressBalanceMap = {};
  final Map _isWatchedMap = {};
  late WalletProvider _walletProvider;
  late ConnectionProvider _connection;
  late Map _listenedAddresses;
  late final int _decimalProduct;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      applyFilter();
      _availableCoin = AvailableCoins.getSpecificCoin(widget.walletName);
      _connection = Provider.of<ConnectionProvider>(context);
      _walletProvider = Provider.of<WalletProvider>(context);
      _listenedAddresses = _connection.listenedAddresses;
      _decimalProduct = AvailableCoins.getDecimalProduct(
        identifier: widget.walletName,
      );
      await fillAddressBalanceMap();
      setState(() {
        _initial = false;
      });
      applyFilter();
    }
    super.didChangeDependencies();
  }

  Future<void> fillAddressBalanceMap() async {
    final utxos = await _walletProvider.getWalletUtxos(widget.walletName);
    for (var tx in utxos) {
      if (tx.value > 0) {
        if (_addressBalanceMap[tx.address] != null) {
          _addressBalanceMap[tx.address] += tx.value;
        } else {
          _addressBalanceMap[tx.address] = tx.value;
        }
      }
    }
  }

  void applyFilter([String? searchedKey]) {
    if (_initial) return;

    var filteredListReceive = <WalletAddress>[];
    var filteredListSend = <WalletAddress>[];

    for (var e in widget.walletAddresses) {
      if (e.isOurs == true) {
        filteredListReceive.add(e);
        //fake watch change address and addresses with balance
        if (_addressBalanceMap[e.address] != null ||
            e.address == _walletProvider.getUnusedAddress(widget.walletName) ||
            e.isWatched == true) {
          _isWatchedMap[e.address] = true;
        } else {
          _isWatchedMap[e.address] = false;
        }
      } else {
        filteredListSend.add(e);
      }
    }

    //apply filters to receive list
    var toRemove = [];
    for (var address in filteredListReceive) {
      if (_showChangeAddresses == false) {
        if (address.isChangeAddr == true) {
          toRemove.add(address);
        }
      }
      if (_showUsed == false) {
        if (address.used == true) {
          toRemove.add(address);
        }
      }
      if (_showUnwatched == false) {
        if (_isWatchedMap[address.address] == false) {
          toRemove.add(address);
        }
      }
      if (_showEmpty == false) {
        if (_addressBalanceMap[address.address] == null) {
          toRemove.add(address);
        }
      }
    }

    for (var address in toRemove) {
      filteredListReceive.remove(address);
    }

    //filter search keys
    if (searchedKey != null) {
      filteredListReceive = filteredListReceive.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName.contains(searchedKey);
      }).toList();
      filteredListSend = filteredListSend.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName.contains(searchedKey);
      }).toList();
    }

    setState(() {
      _filteredReceive = filteredListReceive;
      _filteredSend = filteredListSend;
    });
  }

  Future<void> _addressEditDialog(
    BuildContext context,
    WalletAddress address,
  ) async {
    var textFieldController = TextEditingController();
    textFieldController.text = address.addressBookName;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${AppLocalizations.instance.translate('addressbook_edit_dialog_title')} ${address.address}',
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: textFieldController,
            maxLength: 32,
            decoration: InputDecoration(
              hintText: AppLocalizations.instance
                  .translate('addressbook_edit_dialog_input'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<WalletProvider>().updateOrCreateAddressLabel(
                      identifier: widget.walletName,
                      address: address.address,
                      label: textFieldController.text,
                    );
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddressExportDialog(
    BuildContext context,
    WalletAddress address,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                .translate('addressbook_export_dialog_title'),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_description'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                String wif;
                final navigator = Navigator.of(context);
                void showQrDialog(wif) =>
                    WalletHomeQr.showQrDialog(context, wif);

                if (address.wif.isEmpty) {
                  wif = await context.read<WalletProvider>().getWif(
                        identifier: _availableCoin.name,
                        address: address.address,
                      );
                } else {
                  wif = address.wif;
                }
                navigator.pop();
                showQrDialog(wif);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleSendingAddressesVisilibity() {
    setState(() {
      _showSendingAddresses = !_showSendingAddresses;
    });
  }

  Future<void> _toggleWatched(WalletAddress addr) async {
    String snackText;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    //addresses with balance or currentChangeAddress can not be unwatched
    if (_addressBalanceMap[addr.address] != null ||
        addr.address ==
            _walletProvider.getUnusedAddress(
              widget.walletName,
            )) {
      snackText = 'addressbook_dialog_addr_unwatch_unable';
    } else {
      snackText = _isWatchedMap[addr.address] == true
          ? 'addressbook_dialog_addr_unwatched'
          : 'addressbook_dialog_addr_watched';

      await _walletProvider.updateAddressWatched(
        widget.walletName,
        addr.address,
        !addr.isWatched,
      );

      applyFilter();
      if (_connection.connectionState == BackendConnectionState.connected) {
        if (!_listenedAddresses.containsKey(addr.address) &&
            addr.isWatched == true) {
          //subscribe
          LoggerWrapper.logInfo(
            'AddressTab',
            '_toggleWatched',
            'watched and subscribed ${addr.address}',
          );
          _connection.subscribeToScriptHashes(
            await _walletProvider.getWatchedWalletScriptHashes(
              widget.walletName,
              addr.address,
            ),
          );
        }
      }
    }
    //fire snack
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            snackText,
            {'address': addr.address},
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _addressAddDialog(BuildContext context) async {
    var labelController = TextEditingController();
    var addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('addressbook_add_new'),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.instance.translate('send_address'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.instance
                          .translate('send_enter_address');
                    }
                    var sanitized = value.trim();
                    if (validateAddress(
                          sanitized,
                          _availableCoin.networkType,
                        ) ==
                        false) {
                      return AppLocalizations.instance
                          .translate('send_invalid_address');
                    }
                    //check if already exists
                    if (widget.walletAddresses
                        .any((element) => element.address == value)) {
                      return 'Address already exists';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: labelController,
                  maxLength: 32,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.instance.translate('send_label'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  context.read<WalletProvider>().updateOrCreateAddressLabel(
                        identifier: widget.walletName,
                        address: addressController.text,
                        label: labelController.text == ''
                            ? ''
                            : labelController.text,
                      );
                  applyFilter();
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  String _renderLabel(WalletAddress addr) {
    if (_showLabel) {
      return addr.addressBookName;
    }
    var number = _addressBalanceMap[addr.address] ?? 0;
    return '${(number / _decimalProduct)} ${_availableCoin.letterCode}';
  }

  @override
  Widget build(BuildContext context) {
    var listReceive = <Widget>[];
    var listSend = <Widget>[];
    for (var addr in _filteredSend) {
      listSend.add(
        Align(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width / 3
                : MediaQuery.of(context).size.width,
            child: DoubleTabToClipboard(
              withHintText: false,
              clipBoardData: addr.address,
              child: Card(
                elevation: 0,
                child: ClipRect(
                  child: Slidable(
                    key: Key(addr.address),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 1,
                      children: <Widget>[
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_edit'),
                          backgroundColor: Theme.of(context).primaryColor,
                          icon: Icons.edit,
                          onPressed: (ctx) => _addressEditDialog(ctx, addr),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_share'),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          icon: Icons.share,
                          onPressed: (ctx) => WalletHomeQr.showQrDialog(
                            ctx,
                            addr.address,
                          ),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_send'),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          icon: Icons.send,
                          onPressed: (_) => widget.changeTab(
                            WalletTab.send,
                            addr.address,
                            addr.addressBookName,
                          ),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_delete'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          icon: Icons.delete,
                          onPressed: (ctx) async {
                            await showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  AppLocalizations.instance.translate(
                                    'addressbook_dialog_remove_title',
                                  ),
                                ),
                                content: Text(addr.address),
                                actions: <Widget>[
                                  TextButton.icon(
                                    label: Text(
                                      AppLocalizations.instance.translate(
                                        'server_settings_alert_cancel',
                                      ),
                                    ),
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton.icon(
                                    label: Text(
                                      AppLocalizations.instance
                                          .translate('jail_dialog_button'),
                                    ),
                                    icon: const Icon(Icons.check),
                                    onPressed: () {
                                      context
                                          .read<WalletProvider>()
                                          .removeAddress(
                                            widget.walletName,
                                            addr,
                                          );
                                      applyFilter();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.instance.translate(
                                              'addressbook_dialog_remove_snack',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe_left),
                        ],
                      ),
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
                          child: Text(addr.address),
                        ),
                      ),
                      title: Center(
                        child: Text(
                          addr.addressBookName,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    for (var addr in _filteredReceive) {
      listReceive.add(
        Align(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width / 3
                : MediaQuery.of(context).size.width,
            child: DoubleTabToClipboard(
              withHintText: false,
              clipBoardData: addr.address,
              child: Card(
                elevation: 0,
                child: ClipRect(
                  child: Slidable(
                    key: Key(addr.address),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 1,
                      children: [
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_edit'),
                          backgroundColor: Theme.of(context).primaryColor,
                          icon: Icons.edit,
                          onPressed: (ctx) => _addressEditDialog(ctx, addr),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_share'),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          icon: Icons.share,
                          onPressed: (ctx) => WalletHomeQr.showQrDialog(
                            ctx,
                            addr.address,
                          ),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance.translate(
                            _isWatchedMap[addr.address] == true
                                ? 'addressbook_swipe_unwatch'
                                : 'addressbook_swipe_watch',
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          icon: _isWatchedMap[addr.address] == true
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onPressed: (_) => _toggleWatched(addr),
                        ),
                        SlidableAction(
                          label: AppLocalizations.instance
                              .translate('addressbook_swipe_export'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          icon: Icons.vpn_key,
                          onPressed: (_) => Auth.requireAuth(
                            context: context,
                            biometricsAllowed: context
                                .read<AppSettingsProvider>()
                                .biometricsAllowed,
                            callback: () =>
                                _showAddressExportDialog(context, addr),
                          ),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe_left),
                        ],
                      ),
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
                          child: Text(addr.address),
                        ),
                      ),
                      title: Center(
                        child: Text(
                          _renderLabel(addr),
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    var sliverToBoxAdapter = SliverToBoxAdapter(
      child: Column(
        children: [
          ExpansionTile(
            onExpansionChanged: (newState) => setState(
              () {
                _optionsExpanded = newState;
              },
            ),
            trailing: Icon(
              _optionsExpanded ? Icons.close : Icons.filter_alt,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            title: Text(
              AppLocalizations.instance
                  .translate('addressbook_bottom_bar_your_addresses'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  ChoiceChip(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).shadowColor,
                    visualDensity: const VisualDensity(
                      horizontal: 0.0,
                      vertical: -4,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.instance
                          .translate('addressbook_hide_change'),
                      minFontSize: 10,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    selected: _showChangeAddresses,
                    onSelected: (newState) {
                      setState(() {
                        _showChangeAddresses = newState;
                      });
                      applyFilter();
                    },
                  ),
                  ChoiceChip(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).shadowColor,
                    visualDensity: const VisualDensity(
                      horizontal: 0.0,
                      vertical: -4,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.instance
                          .translate('addressbook_hide_unwatched'),
                      minFontSize: 10,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    selected: _showUnwatched,
                    onSelected: (newState) {
                      setState(() {
                        _showUnwatched = newState;
                      });
                      applyFilter();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(kIsWeb ? 8.0 : 0),
                    child: ChoiceChip(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(context).shadowColor,
                      visualDensity: const VisualDensity(
                        horizontal: 0.0,
                        vertical: -4,
                      ),
                      label: AutoSizeText(
                        _showLabel
                            ? AppLocalizations.instance
                                .translate('addressbook_show_balance')
                            : AppLocalizations.instance
                                .translate('addressbook_show_label'),
                        textAlign: TextAlign.center,
                        minFontSize: 10,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      selected: _showLabel,
                      onSelected: (newState) {
                        setState(
                          () {
                            _showLabel = newState;
                          },
                        );
                        applyFilter();
                      },
                    ),
                  ),
                  ChoiceChip(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).shadowColor,
                    visualDensity: const VisualDensity(
                      horizontal: 0.0,
                      vertical: -4,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.instance
                          .translate('addressbook_hide_used'),
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    selected: _showUsed,
                    onSelected: (newState) {
                      setState(() {
                        _showUsed = newState;
                      });
                      applyFilter();
                    },
                  ),
                  ChoiceChip(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).shadowColor,
                    visualDensity: const VisualDensity(
                      horizontal: 0.0,
                      vertical: -4,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.instance
                          .translate('addressbook_hide_empty'),
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    selected: _showEmpty,
                    onSelected: (newState) {
                      setState(() {
                        _showEmpty = newState;
                      });
                      applyFilter();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                backgroundColor: _search
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).primaryColor,
                title: Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: _search
                      ? Form(
                          key: _formKey,
                          child: Container(
                            padding: const EdgeInsets.only(left: 16),
                            child: TextFormField(
                              autofocus: true,
                              key: _searchKey,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusColor: Colors.red,
                                hintText: AppLocalizations.instance
                                    .translate('addressbook_search'),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  iconSize: 24,
                                  onPressed: () {
                                    _search = false;
                                    applyFilter();
                                  },
                                ),
                              ),
                              onChanged: applyFilter,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width > 1200
                                      ? MediaQuery.of(context).size.width / 5
                                      : MediaQuery.of(context).size.width / 3,
                                  40,
                                ),
                                shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (widget.walletAddresses.isNotEmpty) {
                                  setState(() {
                                    _search = true;
                                  });
                                }
                              },
                              child: Text(
                                AppLocalizations.instance.translate('search'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.surface,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width > 1200
                                      ? MediaQuery.of(context).size.width / 5
                                      : MediaQuery.of(context).size.width / 3,
                                  40,
                                ),
                                shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                _addressAddDialog(context);
                              },
                              child: Text(
                                AppLocalizations.instance
                                    .translate('addressbook_new_button'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SliverAppBar(
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Text(
                  AppLocalizations.instance.translate(
                    'addressbook_bottom_bar_sending_addresses',
                  ),
                  style: kIsWeb
                      ? TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : const TextStyle(),
                ),
                actions: [
                  IconButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    onPressed: () => _toggleSendingAddressesVisilibity(),
                    icon: Icon(
                      _showSendingAddresses
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  _showSendingAddresses ? listSend : [const SizedBox()],
                ),
              ),
              sliverToBoxAdapter,
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverList(
                delegate: SliverChildListDelegate(listReceive),
              ),
            ],
          ),
        ),
      ],
    );
  }
  //TODO does not re-render when new address is generated
}
