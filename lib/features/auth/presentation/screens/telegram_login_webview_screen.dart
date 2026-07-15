import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Hosts the Telegram Login Widget inside the app's own popup-capable
/// WebView (not ASWebAuthenticationSession, which cannot support the
/// window.open()-based popup the widget relies on to complete auth).
///
/// Telegram delivers the signed auth result as a `#tgAuthResult=<base64>`
/// hash fragment appended to the widget page's own URL (observed directly —
/// postMessage-to-opener isn't reliably received here), not as a query-string
/// redirect to a separate callback URL. This screen decodes that fragment
/// client-side and posts it to our backend's widget-callback endpoint (which
/// does the real HMAC verification) to get the one-time exchange code.
///
/// Pops with that code (String) on success, or null if the user closes the
/// sheet manually or something fails.
class TelegramLoginWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String callbackScheme;
  final String widgetCallbackUrl;
  final Dio dio;

  const TelegramLoginWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.callbackScheme,
    required this.widgetCallbackUrl,
    required this.dio,
  });

  @override
  State<TelegramLoginWebViewScreen> createState() =>
      _TelegramLoginWebViewScreenState();
}

class _TelegramLoginWebViewScreenState
    extends State<TelegramLoginWebViewScreen> {
  int? _popupWindowId;
  bool _verifying = false;

  static final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
  );

  Future<NavigationActionPolicy> _handleNavigation(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;

    if (uri.scheme == widget.callbackScheme) {
      if (mounted) Navigator.of(context).pop(uri.queryParameters['code']);
      return NavigationActionPolicy.CANCEL;
    }

    final fragment = uri.fragment;
    if (fragment.startsWith('tgAuthResult=')) {
      _handleTgAuthResult(fragment.substring('tgAuthResult='.length));
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<void> _handleTgAuthResult(String encoded) async {
    setState(() => _verifying = true);
    String? code;
    try {
      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(encoded)));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      code = await _verifyAndGetCode(data);
    } catch (_) {
      code = null;
    }
    if (mounted) Navigator.of(context).pop(code);
  }

  Future<String?> _verifyAndGetCode(Map<String, dynamic> data) async {
    final response = await widget.dio.get<void>(
      widget.widgetCallbackUrl,
      queryParameters: data,
      options: Options(
        followRedirects: false,
        validateStatus: (_) => true,
      ),
    );
    final location = response.headers.value('location');
    if (location == null) return null;
    return Uri.parse(location).queryParameters['code'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Telegram'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            initialSettings: _settings,
            shouldOverrideUrlLoading: _handleNavigation,
            onCreateWindow: (controller, createWindowAction) async {
              setState(() => _popupWindowId = createWindowAction.windowId);
              return true;
            },
          ),
          if (_popupWindowId != null)
            Positioned.fill(
              child: Material(
                child: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _popupWindowId = null),
                        ),
                      ),
                      Expanded(
                        child: InAppWebView(
                          windowId: _popupWindowId,
                          initialSettings: _settings,
                          shouldOverrideUrlLoading: _handleNavigation,
                          onCloseWindow: (controller) {
                            if (mounted) setState(() => _popupWindowId = null);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_verifying)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
