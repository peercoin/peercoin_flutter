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
      var i = 0;

      for (var input in tx.inputs) {
        if (input is TaprootKeyInput) {
          final inputDetails = signDetails[i];
          final sig = signatures[inputDetails.inputN];

          tx = tx.replaceInput(
            input.addSignature(SchnorrInputSignature(sig)),
            i,
          );
          i++;

          return tx;
        }
      }
      break;
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
