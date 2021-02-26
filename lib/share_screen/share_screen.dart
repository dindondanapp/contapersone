import 'package:contapersone/common/auth.dart';
import 'package:contapersone/common/entities.dart';
import 'package:contapersone/common/show_error_dialog.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

import '../common/palette.dart';
import '../common/secret.dart';
import '../counter_screen/counter_screen.dart';

/// A screen that displays a QR code and sharable link for a given counter
class ShareScreen extends StatefulWidget {
  final CounterToken token;
  final Auth auth;
  final bool startCounterButton;

  /// Create a new [ShareScreen] given the [CounterToken] that has to be shared.
  /// If [startCounterButton] is true a button is displayed to start the counter
  ShareScreen(
      {@required this.token,
      @required this.auth,
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
        title: Text(AppLocalizations.of(context).shareScreenTitle),
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
                          AppLocalizations.of(context).shareQrCodeCaption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        margin: EdgeInsets.all(10),
                        child: _url != ''
                            ? QrImage(data: _url, version: QrVersions.auto)
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
                          AppLocalizations.of(context).orShareScreenCaption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildShareButtons()
                    ],
                  ),
                  widget.startCounterButton == null ||
                          !widget.startCounterButton
                      ? Divider()
                      : Container(),
                  widget.startCounterButton == null ||
                          !widget.startCounterButton
                      ? RaisedButton.icon(
                          onPressed: () {
                            _startSubcounter(counterId: widget.token);
                          },
                          label: Text(
                              AppLocalizations.of(context).startOnThisDevice),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
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

  void _startSubcounter({@required CounterToken counterId}) {
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
      final uriString = '${Secret.baseShareURL}?token=${widget.token}';
      String link = kIsWeb
          ? _manualDynamicLink(uriString)
          : await _shortDynamicLink(uriString);
      setState(() {
        _url = link.toString();
        print("Link generated: $_url");
      });
    } catch (error) {
      showErrorDialog(
        context: context,
        title: AppLocalizations.of(context).shareLinkCreationErrorTitle,
        text: AppLocalizations.of(context).shareLinkCreationErrorMessage,
        onRetry: _buildDynamicLink,
      );
    }
  }

  String _manualDynamicLink(String uriString) {
    final encodedUri = Uri.encodeComponent(uriString);
    return 'https://dindondan.page.link/?link=$encodedUri&apn=app.dindondan.contapersone&afl=$encodedUri&ibi=app.dindondan.contapersone&ifl=$encodedUri&isi=1513235116';
  }

  Future<String> _shortDynamicLink(String uriString) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://dindondan.page.link',
      link: Uri.parse(uriString),
      androidParameters: AndroidParameters(
          packageName: 'app.dindondan.contapersone',
          minimumVersion: 0,
          fallbackUrl: Uri.parse(uriString)),
      iosParameters: IosParameters(
          bundleId: 'app.dindondan.contapersone',
          appStoreId: '1513235116',
          minimumVersion: '0.0.0',
          fallbackUrl: Uri.parse(uriString)),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    ShortDynamicLink shortLink =
        await parameters.buildShortLink().timeout(Duration(seconds: 10));

    return shortLink.shortUrl.toString();
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
              ? () => Share.share(
                  '${AppLocalizations.of(context).shareDialogMessage} $_url',
                  subject: AppLocalizations.of(context).shareDialogSubject)
              : null,
        ),
      ]);
    }
  }

  Function get _copyURL {
    if (_url != '') {
      return () {
        Clipboard.setData(ClipboardData(text: _url));
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).linkCopied,
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
