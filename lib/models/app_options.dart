import 'package:hive/hive.dart';

part 'app_options.g.dart';

@HiveType(typeId: 5)
class AppOptionsStore extends HiveObject {
  @HiveField(0, defaultValue: {})
  final Map<String, bool> _authenticationOptions = {
    'walletList': false,
    'walletHome': false,
    'sendTransaction': true,
    'newWallet': false,
  };

  @HiveField(1, defaultValue: false)
  bool _allowBiometrics = false;

  @HiveField(2, defaultValue: '')
  String _defaultWallet = '';

  @HiveField(3, defaultValue: '')
  String _selectedCurrency = '';

  @HiveField(4)
  DateTime? _latestTickerUpdate;

  @HiveField(5, defaultValue: {})
  Map<String, dynamic> _exchangeRates = {};

  @HiveField(6, defaultValue: '')
  String _buildIdentifier = '';

  @HiveField(7, defaultValue: 0)
  int _notificationInterval = 0;

  @HiveField(8, defaultValue: [])
  List<String> _notificationActiveWallets = [];

  @HiveField(9, defaultValue: {})
  Map<String, DateTime> _periodicReminterItemsNextView = {};

  @HiveField(10, defaultValue: false)
  bool _ledgerMode = false;

  AppOptionsStore(
    this._allowBiometrics,
    this._ledgerMode,
  );

  bool get allowBiometrics {
    return _allowBiometrics;
  }

  set allowBiometrics(bool newStatus) {
    _allowBiometrics = newStatus;
    save();
  }

  Map<String, bool> get authenticationOptions {
    return _authenticationOptions;
  }

  String get buildIdentifier {
    return _buildIdentifier;
  }

  set buildIdentifier(String newBuild) {
    _buildIdentifier = newBuild;
    save();
  }

  String get defaultWallet {
    return _defaultWallet;
  }

  set defaultWallet(String newWallet) {
    _defaultWallet = newWallet;
    save();
  }

  Map<String, dynamic> get exchangeRates {
    return _exchangeRates;
  }

  set exchangeRates(Map<String, dynamic> newRates) {
    _exchangeRates = newRates;
    save();
  }

  DateTime get latestTickerUpdate {
    return _latestTickerUpdate ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  set latestTickerUpdate(DateTime newTime) {
    _latestTickerUpdate = newTime;
    save();
  }

  bool get ledgerMode {
    return _ledgerMode;
  }

  set ledgerMode(bool newStatus) {
    _ledgerMode = newStatus;
    save();
  }

  List<String> get notificationActiveWallets {
    return _notificationActiveWallets;
  }

  set notificationActiveWallets(List<String> newList) {
    _notificationActiveWallets = newList;
    save();
  }

  int get notificationInterval {
    return _notificationInterval;
  }

  set notificationInterval(int newInterval) {
    _notificationInterval = newInterval;
    save();
  }

  Map<String, DateTime> get periodicReminterItemsNextView {
    return _periodicReminterItemsNextView;
  }

  set periodicReminterItemsNextView(Map<String, DateTime> newMap) {
    _periodicReminterItemsNextView = newMap;
    save();
  }

  String get selectedCurrency {
    return _selectedCurrency;
  }

  set selectedCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    save();
  }

  void changeAuthenticationOptions(String field, bool value) {
    _authenticationOptions[field] = value;
    save();
  }
}
