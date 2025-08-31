import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Asynchronously open a scanning interface from the provided [context] to
/// aquire a [Uri] from a QR code. When the user scans a QR code the interface
/// closes and the future completes.
Future<Uri> scanUriQRCode(BuildContext context) {
  Completer<Uri> completer = new Completer();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (context) => _ScanScreen(
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
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQrButton),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
            tooltip: AppLocalizations.of(context)!.turnOnFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
            tooltip: AppLocalizations.of(context)!.switchCamera,
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null && widget.scanCallback != null) {
              widget.scanCallback!(barcode.rawValue!);
              if (widget.closeOnScan) {
                Navigator.of(context).pop();
              }
              return;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
