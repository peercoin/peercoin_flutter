import 'package:coinslib/coinslib.dart';

class Coin {
  final String name;
  final String displayName;
  final String letterCode;
  final String iconPath;
  final String iconPathTransparent;
  final String uriCode;
  final NetworkType networkType;
  final int fractions;
  final int minimumTxValue;
  final double fixedFeePerKb;
  final bool fixedFee;
  final String explorerUrl;
  final String genesisHash;
  final int txVersion;
  final double electrumRequiredProtocol;
  final List electrumServers;
  final List<(String, int)> marismaServers;

  Coin({
    required this.name,
    required this.displayName,
    required this.letterCode,
    required this.iconPath,
    required this.iconPathTransparent,
    required this.uriCode,
    required this.networkType,
    required this.fractions,
    required this.minimumTxValue,
    required this.fixedFeePerKb,
    required this.fixedFee,
    required this.explorerUrl,
    required this.genesisHash,
    required this.txVersion,
    required this.electrumRequiredProtocol,
    required this.electrumServers,
    required this.marismaServers,
  });
}
