import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';

Future<SignaturesRequestDetails> generateTaprootSignatureRequestDetails({
  required cl.ECCompressedPublicKey groupKey,
  required int groupKeyIndex,
  required int threshold,
  required List<UtxoFromMarisma> selectedUtxos,
  required String recipientAddress,
  required BigInt txAmount,
  required Duration expiry,
  required String coinIdentifier,
}) async {
  final derivedKeyInfo = HDGroupKeyInfo.master(
    groupKey: groupKey,
    threshold: threshold,
  ).derive(groupKeyIndex);
  final taproot = cl.Taproot(internalKey: derivedKeyInfo.groupKey);
  final program = cl.P2TR.fromTaproot(taproot);
  final coin = AvailableCoins.getSpecificCoin(coinIdentifier);
  final network = coin.networkType;

  final unsignedInputs = selectedUtxos.map((input) {
    return cl.InputCandidate(
      input: cl.TaprootKeyInput(
        prevOut: cl.OutPoint.fromHex(
          input.txid,
          input.vout,
        ),
      ),
      value: BigInt.from(input.amount),
    );
  });

  final coinSelection = cl.CoinSelection.optimal(
    candidates: unsignedInputs,
    recipients: [
      cl.Output.fromAddress(
        txAmount,
        cl.Address.fromString(recipientAddress, network),
      ),
    ],
    changeProgram: program,
    feePerKb: network.feePerKb,
    minFee: network.minFee,
    minChange: network.minOutput,
  );

  final transaction = coinSelection.transaction;

  final allPreviousOutputs = coinSelection.selected
      .map((candidate) => cl.Output.fromProgram(candidate.value, program))
      .toList();

  // Create a list of signing details
  final signDetails = <cl.TaprootKeySignDetails>[];
  for (var i = 0; i < transaction.inputs.length; i++) {
    signDetails.add(
      cl.TaprootKeySignDetails(
        tx: transaction,
        inputN: i,
        prevOuts: allPreviousOutputs,
      ),
    );
  }

  // Convert signing details to signature request details
  final requiredSigs = signDetails
      .map(
        (detail) => SingleSignatureDetails(
          signDetails: SignDetails.keySpend(
            message: cl.TaprootSignatureHasher(detail).hash,
          ),
          groupKey: groupKey,
          hdDerivation: [groupKeyIndex],
        ),
      )
      .toList();

  return SignaturesRequestDetails(
    requiredSigs: requiredSigs,
    expiry: Expiry(expiry),
    metadata: TaprootTransactionSignatureMetadata(
      transaction: transaction,
      signDetails: signDetails,
    ),
  );
}

// TODO prefer GroupKeyInfo instead of passing EcCompressedPublicKey and threshold
