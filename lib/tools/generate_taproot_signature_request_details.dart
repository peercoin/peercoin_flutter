import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';

class UnsignedInput extends cl.InputCandidate {
  final int n;

  UnsignedInput({
    required this.n,
    required super.input,
    required super.value,
  });
}

Future<SignaturesRequestDetails> generateTaprootSignatureRequestDetails({
  required cl.ECCompressedPublicKey groupKey,
  required int groupKeyIndex,
  required List<UtxoFromMarisma> selectedUtxos,
  required String recipientAddress,
  required BigInt txAmount,
  required Duration expiry,
  required String coinIdentifier,
}) async {
  final taproot = cl.Taproot(internalKey: groupKey);
  final program = cl.P2TR.fromTaproot(taproot);
  final coin = AvailableCoins.getSpecificCoin(coinIdentifier);
  final network = coin.networkType;

  final unsignedInputs =
      List<UnsignedInput>.generate(selectedUtxos.length, (i) {
    final input = selectedUtxos[i];
    return UnsignedInput(
      input: cl.TaprootKeyInput(
        prevOut: cl.OutPoint.fromHex(
          input.txid,
          input.vout,
        ),
      ),
      value: BigInt.from(input.amount),
      n: i,
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
    feePerKb: BigInt.from(coin.fixedFeePerKb),
    minFee: BigInt.from(coin.fixedFeePerKb),
    minChange: BigInt.from(coin.minimumTxValue),
  );

  // Create signing details for each selected input
  final trDetails = List<cl.TaprootKeySignDetails>.generate(
    coinSelection.selected.length,
    (i) {
      final input = coinSelection.selected[i];
      return cl.TaprootKeySignDetails(
        tx: coinSelection.transaction,
        inputN: i,
        prevOuts: [cl.Output.fromProgram(input.value, program)],
      );
    },
  );

  // Create the signature request
  return SignaturesRequestDetails(
    requiredSigs: List<SingleSignatureDetails>.generate(
      coinSelection.selected.length,
      (i) {
        return SingleSignatureDetails(
          signDetails: SignDetails.keySpend(
            message: cl.TaprootSignatureHasher(
              trDetails[i],
            ).hash,
          ),
          groupKey: groupKey,
          hdDerivation: [groupKeyIndex],
        );
      },
    ),
    expiry: Expiry(expiry),
    metadata: TaprootTransactionSignatureMetadata(
      transaction: coinSelection.transaction,
      signDetails: trDetails,
    ),
  );
}
