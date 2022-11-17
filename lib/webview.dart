import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPrint extends StatefulWidget {
  final url;

  WebViewPrint({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewPrint> createState() => _WebViewPrintState();
}

class _WebViewPrintState extends State<WebViewPrint> {

  bool isLoading = true;
  late WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },

          ),
          isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          )
              : Stack(),
        ],
      ),
    );
  }
}
