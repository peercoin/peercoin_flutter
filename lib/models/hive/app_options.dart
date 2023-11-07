import 'package:hive/hive.dart';
part 'app_options.g.dart';

@HiveType(typeId: 5)
class AppOptionsStore extends HiveObject {
  @HiveField(0)
  // ignore: prefer_final_fields
  Map<String, bool>? _authenticationOptions = {
    'walletList': false,
    'walletHome': false,
    'sendTransaction': true,
    'newWallet': false,
  };

  @HiveField(1)
  bool? _allowBiometrics = true;

  @HiveField(2)
  String? _defaultWallet = '';

  @HiveField(3)
  String? _selectedCurrency = '';

  @HiveField(4)
  DateTime? _latestTickerUpdate;

  @HiveField(5)
  Map<String, dynamic>? _exchangeRates;

  @HiveField(6)
  String? _buildIdentifier;

  @HiveField(7)
  int? _notificationInterval = 0;

  @HiveField(8)
  List<String>? _notificationActiveWallets = [];

  @HiveField(9, defaultValue: {})
  Map<String, DateTime> _periodicReminterItemsNextView = {};

  @HiveField(10, defaultValue: [])
  List<String> _walletOrder = [];

  @HiveField(11, defaultValue: [])
  List<String> _activatedExperimentalFeatures = [];

  AppOptionsStore(this._allowBiometrics);

  bool get allowBiometrics {
    return _allowBiometrics ?? false;
  }

  set allowBiometrics(bool newStatus) {
    _allowBiometrics = newStatus;
    save();
  }

  Map<String, bool>? get authenticationOptions {
    return _authenticationOptions;
  }

  void changeAuthenticationOptions(String field, bool value) {
    _authenticationOptions![field] = value;
    save();
  }

  String get defaultWallet {
    return _defaultWallet ?? '';
  }

  set defaultWallet(String newWallet) {
    _defaultWallet = newWallet;
    save();
  }

  String get selectedCurrency {
    return _selectedCurrency ?? '';
  }

  set selectedCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    save();
  }

  DateTime get latestTickerUpdate {
    return _latestTickerUpdate ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  set latestTickerUpdate(DateTime newTime) {
    _latestTickerUpdate = newTime;
    save();
  }

  Map<String, dynamic> get exchangeRates {
    return _exchangeRates ?? {};
  }

  set exchangeRates(Map<String, dynamic> newRates) {
    _exchangeRates = newRates;
    save();
  }

  String get buildIdentifier {
    return _buildIdentifier ?? '0';
  }

  set buildIdentifier(String newBuild) {
    _buildIdentifier = newBuild;
    save();
  }

  int get notificationInterval {
    return _notificationInterval ?? 0;
  }

  set notificationInterval(int newInterval) {
    _notificationInterval = newInterval;
    save();
  }

  List<String> get notificationActiveWallets {
    return _notificationActiveWallets ?? [];
  }

  set notificationActiveWallets(List<String> newList) {
    _notificationActiveWallets = newList;
    save();
  }

  Map<String, DateTime> get periodicReminterItemsNextView {
    return _periodicReminterItemsNextView;
  }

  set periodicReminterItemsNextView(Map<String, DateTime> newMap) {
    _periodicReminterItemsNextView = newMap;
    save();
  }

  set walletOrder(List<String> newOrder) {
    _walletOrder = newOrder;
    save();
  }

  List<String> get walletOrder {
    return _walletOrder;
  }

  set activatedExperimentalFeatures(List<String> newFeatures) {
    _activatedExperimentalFeatures = newFeatures;
    save();
  }

  List<String> get activatedExperimentalFeatures {
    return _activatedExperimentalFeatures;
  }
}
