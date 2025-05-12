import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart' as frost;

Future<Transaction> taprootTransactionFinalAssembly(
  frost.SignaturesCompleteClientEvent event,
  frost.Client roastClient,
) async {
  final signatures = event.signatures;
  final request = roastClient.signaturesRequests.firstWhere(
    (request) => request.details.id == event.details.id,
    orElse: () => throw Exception(
      'No request found for ${event.details.id} in ${roastClient.signaturesRequests}',
    ),
  );
  final metadata = request.details.metadata;

  switch (metadata) {
    case frost.TaprootTransactionSignatureMetadata():
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
    case frost.EmptySignatureMetadata():
      //TODO
      break;
    case frost.UnknownSignatureMetadata():
      throw Exception(
        'Unknown metadata type ${metadata.type} for ${event.details.id}',
      );
    default:
      throw Exception(
        'Unknown metadata type ${metadata.runtimeType} for ${event.details.id}',
      );
  }

  throw Exception(
    'No signatures found for ${event.details.id} in ${roastClient.signaturesRequests}',
  );
}
