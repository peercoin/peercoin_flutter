import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/roast/taproot_transaction_final_assembly.dart';

Future<void> assembleTransactionAndBroadcast(
  BuildContext context,
  MarismaClient marismaClient,
  SignaturesCompleteClientEvent event,
) async {
  String? hashHex;
  bool isError = false;

  try {
    final builtTx = await taprootTransactionFinalAssembly(
      event,
    );
    final txHex = builtTx.toHex();
    hashHex = builtTx.hashHex;

    LoggerWrapper.logInfo(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Broadcasting transaction: $hashHex - $txHex',
    );

    final res = await marismaClient.broadCastTransaction(
      BroadCastTransactionRequest(hex: txHex),
    );
    if (res.rpcError.isNotEmpty) {
      LoggerWrapper.logError(
        'ROASTWalletHomeScreen',
        'eventStream',
        'Failed to broadcast transaction: ${res.rpcError}',
      );
      isError = true;
    } else {
      LoggerWrapper.logInfo(
        'ROASTWalletHomeScreen',
        'eventStream',
        'Transaction broadcasted successfully: $hashHex',
      );

      // TODO remove from sigNonces?1
    }
  } catch (e) {
    LoggerWrapper.logError(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Failed to broadcast transaction: $e',
    );
    isError = true;
  } finally {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate(
              isError == false
                  ? 'assemble_transaction_an_broadcast_success_snack'
                  : 'assemble_transaction_an_broadcast_failed_snack',
              {
                'hashHex': hashHex ?? '',
              },
            ),
          ),
        ),
      );
    }
  }
}
