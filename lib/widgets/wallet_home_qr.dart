import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class WalletHomeQr extends StatelessWidget {
  final String _unusedAddress;
  WalletHomeQr(this._unusedAddress);

  static void showQrDialog(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(children: [
          Center(
              child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              width: MediaQuery.of(context).size.width * 1,
              child: Center(
                child: QrImage(
                  data: address,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                child: SelectableText(
                  address,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ElevatedButton.icon(
                icon: Icon(Icons.share),
                onPressed: () => Share.share(address),
                label: Text(
                  AppLocalizations.instance.translate('receive_share')!,
                ))
          ]))
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var inkWell = InkWell(
      onTap: () => showQrDialog(context, _unusedAddress),
      child: QrImage(
        data: _unusedAddress,
        size: 60.0,
        padding: EdgeInsets.all(1),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
    return _unusedAddress == '' ? SizedBox(height: 60, width: 60) : inkWell;
  }
}
