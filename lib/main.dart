import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kauveryhospital/Consts/consts.dart';
import 'package:web_view_tts/web_view_tts.dart';
import 'package:wakelock/wakelock.dart';

import 'api/tokenAPI.dart';
import 'screens/pos_print.dart';

//write documentation for the belwo block of code
//The main function is the entry point of the Flutter application. It calls the runApp function to run the app.
//The runApp function takes the widget that will be the root of the widget tree as the argument.


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final String url=Const.webViewURL;

   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(url)),
              onLoadStart: (controller, url) => onLoadStart(controller),
              initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                  allowContentAccess: true,
                ),
              ),
              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
            ),
            const MainScreen(),
          ],
        ),
      ),
    );
  }

  Future<void> onLoadStart(InAppWebViewController controller) async {
    await WebViewTTS.init(controller: controller);
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TokenGenerationWidget(),
      ),
    );
  }
}


/// The `TokenGenerationWidget` class in Dart is a StatefulWidget that handles token
/// generation and checks for Bluetooth status before proceeding with further
/// actions.
class TokenGenerationWidget extends StatefulWidget {
  @override
  _TokenGenerationWidgetState createState() => _TokenGenerationWidgetState();
}

class _TokenGenerationWidgetState extends State<TokenGenerationWidget> {
  bool isGenerateTokenClicked = false;

  @override
  Widget build(BuildContext context) {
    return isGenerateTokenClicked
        ? Center(
      child: CupertinoActivityIndicator(
        radius: MediaQuery.of(context).size.width / 4,
      ),
    )
        : TokenGenerationView(
      onPressed: () async {
        setState(() {
          isGenerateTokenClicked = true;
        });
        var token = await ApiHelper().getToken(context);
        if(token ==null)
          { setState(() {
            isGenerateTokenClicked = false;
          });

          }
        else
          {
        await IsBluetoothEnabled(context, token);}
      },
    );
  }

  Future<void> IsBluetoothEnabled(BuildContext context, int token) async {
    print("FLUTTER BLUE CHECK");
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    bool on = await flutterBlue.isOn;
    print("ONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN$on");

    if (on) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintingWidget(currenttoken: token),
        ),
      );
      setState(() {
        isGenerateTokenClicked = false;
      });
    } else {
       _showBluetoothAlertDialog(context);
      setState(() {
        isGenerateTokenClicked = false;
      });
    }
  }

  void _showBluetoothAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);

      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("புளூடூத் | Bluetooth"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("டோக்கனை உருவாக்கும் முன் புளூடூத்தை இயக்கவும்"),
          Text("Please enable Bluetooth before generating token"),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

/// The `TokenGenerationView` class in Dart represents a widget for generating
/// tokens with a button to collect the token upon tap.


class TokenGenerationView extends StatelessWidget {
  final VoidCallback onPressed;

  TokenGenerationView({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset("asset/Kauvery_Logo.png",
            ),
          ),
          Container(
            color: Color(0xffc01c7b),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "",
                      style: TextStyle(
                        backgroundColor: Color(0xffc01c7b),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "",
                      style: TextStyle(
                        backgroundColor: Color(0xffc01c7b),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextButton(
              onPressed: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffc01c7b)),
                  color: Color(0xffffcf78),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 0),
                  child: Center(
                    child: Column(
                      children: [
                        Spacer(),
                        Text(
                          "Tap once to collect token",
                          style: TextStyle(
                            color: Color(0xffc01c7b),
                            fontSize: MediaQuery.of(context).size.width / 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          "டோக்கனை சேகரிக்க ஒருமுறை தட்டவும்",
                          style: TextStyle(
                            color: Color(0xffc01c7b),
                            fontSize: MediaQuery.of(context).size.width / 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }
}
