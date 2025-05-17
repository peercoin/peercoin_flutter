import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

Future<Transaction> taprootTransactionFinalAssembly(
  SignaturesCompleteClientEvent event,
) async {
  final signatures = event.signatures;
  final metadata = event.details.metadata;

  switch (metadata) {
    case TaprootTransactionSignatureMetadata():
      final signDetails = metadata.signDetails;
      var tx = metadata.transaction;

      for (int i = 0; i < signatures.length; i++) {
        final inputN = signDetails[i].inputN;
        final input = tx.inputs[inputN];

        if (input is TaprootKeyInput) {
          tx = tx.replaceInput(
            input.addSignature(SchnorrInputSignature(signatures[i])),
            inputN,
          );
        }
      }
      return tx;

    case EmptySignatureMetadata():
      //TODO
      break;
    case UnknownSignatureMetadata():
      throw Exception(
        'Unknown metadata type ${metadata.type} for ${event.details.id}',
      );
    default:
      throw Exception(
        'Unknown metadata type ${metadata.runtimeType} for ${event.details.id}',
      );
  }

  throw Exception(
    'No transaction found for ${event.details.id}',
  );
}
