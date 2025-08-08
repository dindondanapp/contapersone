import 'package:contapersone/common/auth.dart';
import 'package:contapersone/common/entities.dart';
import 'package:contapersone/common/show_error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contapersone/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../common/palette.dart';
import '../counter_screen/counter_screen.dart';

/// A screen that displays a QR code and sharable link for a given counter
class ShareScreen extends StatefulWidget {
  final CounterToken token;
  final Auth auth;
  final bool startCounterButton;

  /// Create a new [ShareScreen] given the [CounterToken] that has to be shared.
  /// If [startCounterButton] is true a button is displayed to start the counter
  ShareScreen(
      {required this.token,
      required this.auth,
      this.startCounterButton = false});

  @override
  State<StatefulWidget> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _url = '';

  @override
  void initState() {
    super.initState();

    _buildDynamicLink();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shareScreenTitle),
        backgroundColor: Palette.primary,
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: () {
                return [
                  Column(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)!.shareQrCodeCaption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        margin: EdgeInsets.all(10),
                        child: _url != ''
                            ? QrImageView(data: _url, version: QrVersions.auto)
                            : Container(
                                width: 200,
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)!.orShareScreenCaption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildShareButtons()
                    ],
                  ),
                  !widget.startCounterButton ? Divider() : Container(),
                  !widget.startCounterButton
                      ? ElevatedButton.icon(
                          onPressed: () {
                            _startSubcounter(counterId: widget.token);
                          },
                          label: Text(
                              AppLocalizations.of(context)!.startOnThisDevice),
                          icon: Icon(Icons.arrow_forward),
                        )
                      : Container(),
                ];
              }(),
            ),
          ),
        ),
      ),
    );
  }

  void _startSubcounter({required CounterToken counterId}) {
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              CounterScreen(token: counterId, auth: widget.auth)),
    );
  }

  void _buildDynamicLink() async {
    try {
      print("Generating link…");
      // Generate direct link that works with Universal Links and App Links
      final link =
          'https://dindondan.app/contapersone/web/?token=${widget.token}';
      setState(() {
        _url = link;
        print("Link generated: $_url");
      });
    } catch (error) {
      showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.shareLinkCreationErrorTitle,
        text: AppLocalizations.of(context)!.shareLinkCreationErrorMessage,
        onRetry: _buildDynamicLink,
      );
    }
  }

  Widget _buildShareButtons() {
    if (kIsWeb) {
      return Row(children: [
        Expanded(
          child: SelectableText(
            _url,
            maxLines: 1,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
        ),
        IconButton(
          icon: Icon(Icons.content_copy),
          onPressed: _copyURL,
        ),
      ]);
    } else {
      return Row(children: [
        Expanded(
          child: SelectableText(
            _url,
            maxLines: 1,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
        ),
        IconButton(
          icon: Icon(Icons.content_copy),
          onPressed: _copyURL,
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: _url != ''
              ? () => Share.shareUri(
                    Uri.parse(_url),
                  )
              : null,
        ),
      ]);
    }
  }

  Function()? get _copyURL {
    if (_url != '') {
      return () {
        Clipboard.setData(ClipboardData(text: _url));
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.linkCopied,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.grey,
            timeInSecForIosWeb: 3);
      };
    } else {
      return null;
    }
  }
}
