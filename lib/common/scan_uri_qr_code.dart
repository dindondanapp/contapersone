import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

Future<Uri> scanUriQRCode(BuildContext context) async {
  Completer<Uri> completer = new Completer();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ScanScreen(
        scanCallback: (result) {
          try {
            final uri = Uri.parse(result);
            completer.complete(uri);
          } catch (error) {
            completer.completeError(error);
          }
        },
      ),
    ),
  );

  return completer.future;
}

class ScanScreen extends StatefulWidget {
  final void Function(String result) scanCallback;
  final bool closeOnScan;

  const ScanScreen({Key key, this.scanCallback, this.closeOnScan = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool flashOn = false;

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey();

  _ScanScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scansiona codice QR'),
        actions: [
          IconButton(
            icon: Icon(flashOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () {
              controller.toggleFlash();
              setState(() => flashOn = !flashOn);
            },
            tooltip: flashOn ? 'Accendi flash' : 'Spegni flash',
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () {
              controller.flipCamera();
            },
            tooltip: 'Cambia fotocamera',
          ),
        ],
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 40,
          borderWidth: 5,
          cutOutSize: 280,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (widget.scanCallback != null) {
        widget.scanCallback(scanData);
      }
      if (widget.closeOnScan) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
