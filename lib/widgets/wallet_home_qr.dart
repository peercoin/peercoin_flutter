import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletHomeQr extends StatelessWidget {
  final String? _unusedAddress;
  WalletHomeQr(this._unusedAddress);
  @override
  Widget build(BuildContext context) {
    return _unusedAddress == ''
        ? SizedBox(height: 60, width: 60)
        : InkWell(
            onTap: () {
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
                              data: _unusedAddress!,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            child: SelectableText(
                              _unusedAddress!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ]))
                    ]);
                  });
            },
            child: QrImage(
              data: _unusedAddress!,
              size: 60.0,
              padding: EdgeInsets.all(1),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          );
  }
}
