import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/roast/taproot_transaction_final_assembly.dart';

Future<void> assembleTransactionAndBroadcast(
  BuildContext context,
  MarismaClient marismaClient,
  ROASTWallet wallet,
  SignaturesCompleteClientEvent event,
) async {
  String? txId;
  bool isError = false;
  bool isBroadcasted = false;

  try {
    final builtTx = await taprootTransactionFinalAssembly(
      event,
    );
    final txHex = builtTx.toHex();
    txId = builtTx.txid;

    //check if txid already exists in broadcastedTxIds
    if (wallet.broadcastedTxIds.contains(txId)) {
      LoggerWrapper.logError(
        'ROASTWalletHomeScreen',
        'eventStream',
        'Transaction already broadcasted: $txId',
      );
      isBroadcasted = true;
      return;
    }

    LoggerWrapper.logInfo(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Broadcasting transaction: $txId - $txHex',
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
        'Transaction broadcasted successfully: $txId',
      );

      //add txId to broadcastedTxIds
      final ourList = wallet.broadcastedTxIds;
      ourList.add(txId);
      wallet.broadcastedTxIds = ourList;
    }
  } catch (e) {
    LoggerWrapper.logError(
      'ROASTWalletHomeScreen',
      'eventStream',
      'Failed to broadcast transaction: $e',
    );
    isError = true;
  } finally {
    if (context.mounted && !isBroadcasted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate(
              isError == false
                  ? 'assemble_transaction_an_broadcast_success_snack'
                  : 'assemble_transaction_an_broadcast_failed_snack',
              {
                'txId': txId ?? '',
              },
            ),
          ),
        ),
      );
    }
  }
}
