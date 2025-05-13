import 'package:flutter/widgets.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/roast/taproot_transaction_final_assembly.dart';

Future<void> assembleTransactionAndBroadcast(
  BuildContext context,
  MarismaClient marismaClient,
  SignaturesCompleteClientEvent event,
) async {
  try {
    final builtTx = await taprootTransactionFinalAssembly(
      event,
    );
    LoggerWrapper.logInfo(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Broadcasting transaction: ${builtTx.hashHex} - ${builtTx.toHex()} ',
    );
    final res = await marismaClient.broadCastTransaction(
      BroadCastTransactionRequest(hex: builtTx.toHex()),
    );
    if (res.rpcError.isNotEmpty) {
      LoggerWrapper.logError(
        'ROASTWalletHomeScreen',
        'eventStream',
        'Failed to broadcast transaction: ${res.rpcError}',
      );
    } else {
      LoggerWrapper.logInfo(
        'ROASTWalletHomeScreen',
        'eventStream',
        'Transaction broadcasted successfully: ${builtTx.hashHex}',
      );
      // TODO show success snackbar

      // TODO remove from sigNonces?1
    }
  } catch (e) {
    LoggerWrapper.logError(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Failed to broadcast transaction: $e',
    );
  }
}
