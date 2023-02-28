import 'dart:async';
import 'dart:io';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:kauveryhospital/screens/pos_print.dart';
import 'package:kauveryhospital/screens/token.dart';

import 'package:kauveryhospital/webview.dart';
import 'package:signalr_flutter/signalr_api.dart';
import 'package:signalr_flutter/signalr_flutter.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:web_view_tts/web_view_tts.dart';

import 'api/tokenAPI.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Demo Shop",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: +919591708470',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'No',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Item',
          width: 5,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Price',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(text: "1", width: 1),
      PosColumn(
          text: "Tea",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "10",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "10", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "2", width: 1),
      PosColumn(
          text: "Sada Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "30",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "3", width: 1),
      PosColumn(
          text: "Masala Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "50",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "4", width: 1),
      PosColumn(
          text: "Rova Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "70",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: "160",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  InAppWebViewController? webViewController;

  onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "http://signalr.timesmed.com/Login/KaveriLogin")),
                onLoadStart: (cntrl, url) => onLoadStart(cntrl),
                initialOptions: InAppWebViewGroupOptions(
                    android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                  allowContentAccess: true,
                )),
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }),
            Main(),
          ],
        ),
      ),
    );
  }
}

class Main extends StatefulWidget {
  Main({
    Key? key,
  }) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  InAppWebViewController? webViewController;

  onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);
  }

  bool isGenerateTokenClicked = false;
@override
  void initState() {
  isGenerateTokenClicked = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:isGenerateTokenClicked?Center(child: CupertinoActivityIndicator(radius: MediaQuery.of(context).size.width/4,)): Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Image.asset(
                  "asset/Kauvery_Logo.png",
                ),
              ),

              Container(
                color: Color(0xffc01c7b),
                // width: MediaQuery.of(context).size.width,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Column(children: [
                    Text(
                      "",
                      style: TextStyle(
                          backgroundColor: Color(0xffc01c7b),
                          color: Colors.white),
                    ),
                    Text(
                      "",
                      style: TextStyle(
                          backgroundColor: Color(0xffc01c7b),
                          color: Colors.white),
                    )
                  ])),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextButton(
                    onPressed: isGenerateTokenClicked == false
                        ? () async {
                            setState(() {
                              isGenerateTokenClicked = true;
                            });
                            var token = await ApiHelper().GetToken();
                            await IsBluethoothEnabled(context, token);
                          }
                        : () {
                            print(isGenerateTokenClicked);
                          },
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
                                  "Tap once to",
                                  style: TextStyle(
                                    color: Color(0xffc01c7b),
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "collect token",
                                  style: TextStyle(
                                    color: Color(0xffc01c7b),
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            11,
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
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Spacer(),
                              ],
                            ),
                          )),
                    )),
              ),
              Expanded(flex: 1, child: SizedBox()),

              // Container(
              //   padding: EdgeInsets.all(20),
              //   child: Column(
              //     children: [
              //       Text("Search Paired Bluetooth"),
              //       TextButton(
              //         onPressed: () {
              //           this.getBluetooth();
              //         },
              //         child: Text("Search"),
              //       ),
              //       Container(
              //         height: 100,
              //         child: ListView.builder(
              //           itemCount: availableBluetoothDevices.length > 0
              //               ? availableBluetoothDevices.length
              //               : 0,
              //           itemBuilder: (context, index) {
              //             return ListTile(
              //               onTap: () {
              //                 String select = availableBluetoothDevices[index];
              //                 List list = select.split("#");
              //                 // String name = list[0];
              //                 String mac = list[1];
              //                 this.setConnect(mac);
              //               },
              //               title: Text('${availableBluetoothDevices[index]}'),
              //               subtitle: Text("Click to connect"),
              //             );
              //           },
              //         ),
              //       ),
              //       SizedBox(
              //         height: 30,
              //       ),
              //       TextButton(
              //         onPressed: connected ? this.printGraphics : null,
              //         child: Text("Print"),
              //       ),
              //       TextButton(
              //         onPressed: connected ? this.printTicket : null,
              //         child: Text("Print Ticket"),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  IsBluethoothEnabled(context, token) async {
    print("FLUTTER BLUE CHECK");
    showAlertDialog(BuildContext context) {
      // set up the button
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Bluetooth"),
        content: Text("Please enable Bluetooth before generating token"),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    bool on = await flutterBlue.isOn;
    print("ONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN$on");
    if(on)
        {
             await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrintingWidget(currenttoken: token)),
            );
             setState(() {
               isGenerateTokenClicked=false;
             });

          }
       else{ showAlertDialog(context);}
  }
}

