import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// Asynchronously open a scanning interface from the provided [context] to
/// aquire a [Uri] from a QR code. When the user scans a QR code the interface
/// closes and the future completes.
Future<Uri> scanUriQRCode(BuildContext context) {
  Completer<Uri> completer = new Completer();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _ScanScreen(
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

class _ScanScreen extends StatefulWidget {
  final void Function(String result)? scanCallback;
  final bool closeOnScan;

  const _ScanScreen({Key? key, this.scanCallback, this.closeOnScan = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<_ScanScreen> {
  bool flashOn = false;

  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey();

  _ScanScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQrButton),
        actions: [
          IconButton(
            icon: Icon(flashOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () {
              controller?.toggleFlash();
              setState(() => flashOn = !flashOn);
            },
            tooltip: flashOn
                ? AppLocalizations.of(context)!.turnOnFlash
                : AppLocalizations.of(context)!.turnOffFlash,
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () {
              controller?.flipCamera();
            },
            tooltip: AppLocalizations.of(context)!.switchCamera,
          ),
        ],
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
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
      if (scanData.code != null && widget.scanCallback != null) {
        widget.scanCallback!(scanData.code!);
        controller.dispose();
      }
      if (widget.closeOnScan) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
