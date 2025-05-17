import 'package:grpc/grpc.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/tools/logger_wrapper.dart';

/// Returns a MarismaClient and a function to shutdown the channel.
/// The wallet name is used to get the specific coin's Marisma server details.
/// The client is created using the URL and port from the specified wallet name.
/// The function should be called when the client is no longer needed.

(MarismaClient, Future<void> Function()) getMarismaClient(String walletName) {
  final (url, port) =
      AvailableCoins.getSpecificCoin(walletName).marismaServers.first;

  final channel = ClientChannel(
    url,
    port: port,
  );

  final client = MarismaClient(channel);

  // Return both the client and a shutdown function
  return (
    client,
    () async {
      LoggerWrapper.logInfo(
        'MarismaClient',
        'getMarismaClient',
        'Shutting down channel for $walletName',
      );

      await channel.shutdown();
    }
  );
}
