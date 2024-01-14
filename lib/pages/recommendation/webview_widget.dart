import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class NotedWebView extends StatefulWidget {
  const NotedWebView({super.key, required this.url});

  final String url;

  @override
  State<NotedWebView> createState() => _NotedWebViewState();
}

class _NotedWebViewState extends State<NotedWebView> {
  late final WebViewController _controller;

  String? getCodeFromUrl(String url) {
    var decoded = Uri.decodeFull(url);

    RegExp regExp = RegExp(r'code=([^&]+)');
    RegExpMatch? match = regExp.firstMatch(decoded);

    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) "
          "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile "
          "Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            if (url.startsWith(
                "https://notes-are-noted.vercel.app/authenticate/google")) {
              var code = getCodeFromUrl(url);

              Navigator.pop(context, code);
            }
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);

      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    WebViewCookieManager().clearCookies();

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
      floatingActionButton: closeButton(),
    );
  }

  Widget closeButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Icon(Icons.close),
    );
  }
}
