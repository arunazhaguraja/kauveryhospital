import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:web_view_tts/web_view_tts.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart' as WV;
import 'package:widgets_to_image/widgets_to_image.dart';

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../utlity/blue_print.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }


  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

FlutterBlue flutterBlue = FlutterBlue.instance;

class PrintingWidget extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  final currenttoken;

   PrintingWidget({Key? key, this.currenttoken}) : super(key: key);

  @override
  _PrintingWidgetState createState() => _PrintingWidgetState();
}

class _PrintingWidgetState extends State<PrintingWidget> {
  List<ScanResult>? scanResult;
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  late File imgFile;

  @override
  void initState() {
    super.initState();
    findDevices();
  }

  void findDevices() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResult = results;
      });
    });
    flutterBlue.stopScan();
  }

  getSetImage() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    imgFile = File(
      '$directory/photo.png',
    );
    Uint8List? pngBytes = await controller.capture();
    await imgFile.writeAsBytes(pngBytes!);
    return imgFile.path;
  }

  void printWithDevice(BluetoothDevice device) async {
    await device.connect();
    final gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
    final printer = BluePrint();
    print("PPPPPPPPPPPPPPPPPPPPPPP ${printer.toString()}");
    //printer.add(gen.hr());
    printer.add(gen.image(getSetImage()));

    // printer.add(gen.text(widget.currenttoken.toString(),styles: PosStyles(height: PosTextSize.size1)));
    // printer.add(gen.qrcode('${widget.currenttoken} ${now.toString()}',),);
    // var currenttokendatenow = '${widget.currenttoken} ${now.toString()}'.split(',');
    // printer.add(gen.barcode(Barcode.code39([currenttokendatenow])));
    // printer.add(gen.barcode(Barcode.code39(widget.currenttoken.tolist())));
    //printer.add(gen.text('${widget.currenttoken} ${now.toString()}',),);
    //printer.add(gen.feed(1));
    printer.add(gen.cut());
    print("PPPPPPPPPPPPPPPPPPPPPPP ${printer.toString()}");
    await printer.printData(device);

    device.disconnect();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => Main()));
  }

  final now = DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now());
  @override
  late WV.WebViewController _controller;

  InAppWebViewController? webViewController;

  onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);

  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse("http://signalr.timesmed.com/Login/KaveriLogin")),

                onLoadStart: (cntrl, url) => onLoadStart(cntrl),
                initialOptions: InAppWebViewGroupOptions(
                    android: AndroidInAppWebViewOptions(
                      useHybridComposition: true,
                      allowContentAccess: true,
                    )),
                androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
                  return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                }

            ),
            // FutureBuilder(builder: (context,snap){
            //   return _launchURL(context);
            // }),
            // WV.WebView(
            //   javascriptMode: WV.JavascriptMode.unrestricted,
            //   initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            //   allowsInlineMediaPlayback: true,
            //
            //   initialUrl: 'http://signalr.timesmed.com/Login/KaveriLogin',
            //   onWebViewCreated: (controller) {
            //     _controller = controller;
            //   },
            //
            //   // onPageFinished: (_) async {
            //   //
            //   //   final String username = "Dashboarduser";
            //   //   final String password = "121212";
            //   //
            //   //   _controller.runJavascript('''
            //   //                document.getElementById("usrname").value = '$username';
            //   //               ''');
            //   //   _controller.runJavascript('''
            //   //   document.getElementById("password").value ='$password';
            //   //                ''');
            //   //
            //   //   await Future.delayed(Duration(seconds: 1));
            //   //   _controller.runJavascript(
            //   //       "document.getElementsByClassName('btn').logClick.click();");
            //   // },
            //
            // ),
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetsToImage(
                        controller: controller,
                        child: Container(
                          height: 300,
                          width: 300,
                          child: DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.currenttoken,
                                  style: TextStyle(fontSize: 100),
                                ),
                                Container(
                                  height: 80,
                                  child: SfBarcodeGenerator(
                                    value:
                                        "${widget.currenttoken} ${now.toString()}",
                                    showValue: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Select Printer Device to print",
                        style: TextStyle(color: Color(0xffc01c7b)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0xffc01c7b)),
                          ),
                          height: 300,
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(scanResult![index].device.name),
                                subtitle: Text(scanResult![index].device.id.id),
                                onTap: () => {
                                  scanResult![index].device.disconnect(),
                                  printWithDevice(scanResult![index].device)
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: scanResult?.length ?? 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),



          // Center(
          //   child: ElevatedButton(
          //       onPressed: () async {
          //         await
          //           widget.browser.open(
          //             url: Uri.parse("http://signalr.timesmed.com/Login/KaveriLogin"),
          //             );
          //       },
          //       child: Text("Open Chrome Safari Browser")),
          // )

          ],
        ),
      ),
    );
  }

   _launchURL(BuildContext context) async {
    try {
      await launch(
        'http://signalr.timesmed.com/Login/KaveriLogin',
        customTabsOption: const CustomTabsOption(
          enableDefaultShare: false,
          enableUrlBarHiding: false,
          showPageTitle: false,
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }

}
