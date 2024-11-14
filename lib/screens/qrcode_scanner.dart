import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(ModalRoute.of(context)!.settings.arguments as String),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                _buildQrView(context),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () async => await controller.toggleFlash(),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(
    QRViewController controller,
  ) async {
    setState(() {
      this.controller = controller;
    });

    if (Platform.isAndroid) {
      await controller.pauseCamera();
      await controller.resumeCamera();
    }

    controller.scannedDataStream.listen(
      (scanData) async {
        controller.dispose();
        if (!mounted) return;
        await Navigator.maybeOf(context)!.maybePop(scanData.code);
      },
    );
  }
}
