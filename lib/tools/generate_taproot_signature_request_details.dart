import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:flutter/foundation.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';

Future<SignaturesRequestDetails> generateTaprootSignatureRequestDetails({
  required cl.ECCompressedPublicKey groupKey,
  required int groupKeyIndex,
  required UtxoFromMarisma selectedUtxo,
  required String recipientAddress,
  required int txAmount,
  required Duration expiry,
  required String coinIdentifier,
}) async {
  final taproot = cl.Taproot(internalKey: groupKey);
  final program = cl.P2TR.fromTaproot(taproot);
  final coin = AvailableCoins.getSpecificCoin(coinIdentifier);
  final network = coin.networkType;

  final unsignedInput = cl.TaprootKeyInput(
    prevOut: cl.OutPoint.fromHex(
      selectedUtxo.txid,
      selectedUtxo.vout,
    ),
  );

  final coinSelection = cl.CoinSelection.optimal(
    candidates: [
      cl.InputCandidate(
        input: cl.Input.match(
          cl.RawInput(
            prevOut: cl.OutPoint.fromHex(
              selectedUtxo.txid,
              selectedUtxo.vout,
            ),
            scriptSig: Uint8List(0), // FIXME definetly wrong
          ),
        ),
        value: BigInt.from(selectedUtxo.amount),
      ),
    ],
    recipients: [
      cl.Output.fromAddress(
        BigInt.from(txAmount),
        cl.Address.fromString(recipientAddress, network),
      ),
    ],
    changeProgram: program, // FIXME probably wrong
    feePerKb: BigInt.from(coin.fixedFeePerKb),
    minFee: BigInt.from(coin.fixedFeePerKb),
    minChange: BigInt.from(coin.minimumTxValue),
  );

  final unsignedTx = cl.Transaction(
    inputs: [unsignedInput],
    outputs: coinSelection.recipients,
  );

  final trDetails = cl.TaprootKeySignDetails(
    tx: unsignedTx,
    inputN: 0,
    prevOuts: [
      cl.Output.fromProgram(
        BigInt.from(selectedUtxo.amount),
        program,
      ), // FIXME likely wrong?
    ],
  );

  // Sign signature hash
  return SignaturesRequestDetails(
    requiredSigs: [
      SingleSignatureDetails(
        signDetails: SignDetails.keySpend(
          message: cl.TaprootSignatureHasher(trDetails).hash,
        ),
        groupKey: groupKey,
        hdDerivation: [groupKeyIndex],
      ),
    ],
    expiry: Expiry(expiry),
    metadata: TaprootTransactionSignatureMetadata(
      transaction: unsignedTx,
      signDetails: [trDetails],
    ),
  );
}
