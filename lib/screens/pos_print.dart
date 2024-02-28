import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:web_view_tts/web_view_tts.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart' as WV;
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../main.dart';

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

FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => AutoSelectandprintToken());
  }

  @override
  void dispose() {
    scanResult?.clear();
    super.dispose();
  }

  void findDevices() async {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          scanResult = results;
        });
      }
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

   printWithDevice(BluetoothDevice device) async {
    List<int> bytes = [];
    await device.connect();
    final gen = Generator(PaperSize.mm80, await CapabilityProfile.load());
    final printer = BluePrint();

    final List<int> barData = [1, 2, 3, 4];
    //bytes += gen.barcode(Barcode.upcA(barData));
    //printer.add(gen.barcode(Barcode.code39(barData)));

    // print("PPPPPPPPPPPPPPPPPPPPPPP ${printer.toString()}");
    // var imgflieename=await getSetImage();
    // print("Image Name $imgflieename");
    //final ByteData data = await rootBundle.load(imgflieename);
    // final Uint8List? bytes =  await controller.capture();
    // final img.Image image = img.decodeImage(bytes!)!;
    // printer.add(gen.imageRaster(image));
    printer.add(gen.text('${widget.currenttoken}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1));
    // printer.add(
    //   gen.text(
    //       '${widget.currenttoken}',
    //       styles:  PosStyles(align: PosAlign.center,bold: true,)
    //   ),
    // );
    // printer.add(
    //   gen.qrcode('${widget.currenttoken} ${now.toString()}',
    //       size: QRSize.Size8, align: PosAlign.center),
    // );
    // print( '${widget.currenttoken} ${now.toString()}');
    // List<String> currenttokendatenow = '${widget.currenttoken.toString()}'.split('');
    // print( 'CCCCCCCCCCCCCCCCCCCCC$currenttokendatenow');
    //printer.add(gen.barcode(Barcode.code39([1,2,3]),textPos:BarcodeText.none, ));
    //printer.add(gen.barcode(Barcode.code39(currenttokendatenow),textPos: BarcodeText.none));
    //printer.add(gen.barcode(Barcode.code39([1,2,3])));
    printer.add(gen.emptyLines(1));

    printer.add(
      gen.text('${now.toString()}', styles: PosStyles(align: PosAlign.center)),
    );
    //printer.add(gen.feed(1));
    printer.add(gen.cut());
    print("PPPPPPPPPPPPPPPPPPPPPPP ${printer._data.toString()}");

    await printer.printData(device);

    device.disconnect();
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (c) => Main()));
  }

  final now = DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now());
  final nowTime = DateFormat("ddMMHHmm").format(DateTime.now());
  @override
  late WV.WebViewController _controller;

  InAppWebViewController? webViewController;

  onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);
  }

  bool onTapped = false;

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(

        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
            Text("Printing..."),
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget build(BuildContext context) {
    //showAlertDialog(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: AbsorbPointer(
        absorbing: true,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height / 20),
                        child: DottedBorder(
                          color: Colors.black,
                          strokeWidth: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.currenttoken.toString(),
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height / 5),
                              ),
                              Container(
                                height: 80,
                                child: SfBarcodeGenerator(
                                  textStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                              50),
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
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //SizedBox(height: M  ediaQuery.of(context).size.height/5,),
                        Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 40),
                          child: Center(
                            child: CupertinoActivityIndicator(
                              radius: MediaQuery.of(context).size.width / 7,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 40),
                          child: Text(
                            "அச்சிடுதல் தயவு செய்து காத்திருக்கவும்",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 30,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height / 40),
                          child: Center(
                              child: Text(
                            "Printing please wait",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 30,
                            ),
                            textAlign: TextAlign.center,
                          )),
                        ),

                        //SizedBox(height: MediaQuery.of(context).size.height/5,),
                      ],
                    ),
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       WidgetsToImage(
              //         controller: controller,
              //         child: Container(
              //           height: 300,
              //           width: 300,
              //           child: DottedBorder(
              //             color: Colors.black,
              //             strokeWidth: 1,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Text(
              //                   widget.currenttoken,
              //                   style: TextStyle(fontSize: 100),
              //                 ),
              //                 Container(
              //                   height: 80,
              //                   child: SfBarcodeGenerator(
              //                     value:
              //                         "${widget.currenttoken} ${now.toString()}",
              //                     showValue: true,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       //  SizedBox(
              //       //    height: 10,
              //       //  ),
              //       //  Text(
              //       //    "Select Printer Device to print",
              //       //    style: TextStyle(color: Color(0xffc01c7b)),
              //       //  ),
              //       // onTapped?SizedBox(
              //       //     height:100,child: Center(child: CircularProgressIndicator())): Padding(
              //       //    padding: const EdgeInsets.all(8.0),
              //       //    child: Container(
              //       //      decoration: BoxDecoration(
              //       //        borderRadius: BorderRadius.circular(10),
              //       //        border: Border.all(color: Color(0xffc01c7b)),
              //       //      ),
              //       //      height: 300,
              //       //      child: ListView.separated(
              //       //        itemBuilder: (context, index) {
              //       //          return ListTile(
              //       //            title: Text(scanResult![index].device.name),
              //       //            subtitle: Text(scanResult![index].device.id.id),
              //       //            onTap: () => {
              //       //              setState(()  {
              //       //           onTapped=true;
              //       //              }),
              //       //              scanResult![index].device.disconnect(),
              //       //              printWithDevice(scanResult![index].device)
              //       //            },
              //       //          );
              //       //        },
              //       //        separatorBuilder: (context, index) =>
              //       //            const Divider(),
              //       //        itemCount: scanResult?.length ?? 0,
              //       //      ),
              //       //    ),
              //       //  ),
              //     ],
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }

  AutoSelectandprintToken() {
    bool found = false;
    int k = 0;
    found
        ? null
        : Timer.periodic(Duration(seconds: 2), (timer) async{
            if (scanResult == null) {
              print("NOPPPPEE");
            } else {
              for (int i = 0; i < (scanResult!.length); i++) {
                print(
                    "SSSSSSSSSSSSSSSSSSSSSSSSS${scanResult![i].device.id.id.toString()}");
                //Kavery alwarpet
                //final ip= '03:12:44:DA:57:3C';
                //Kavery trichy
                final ip='DC:0D:30:01:B1:AA';
                if ('${scanResult![i].device.id.id}' == ip) {
                  found = true;
                  scanResult![i].device.disconnect();
                  timer.cancel();
                  await printWithDevice(scanResult![i].device);
                  Navigator.pop(context);
                  break;
                }
              }
              k++;

              found
                  ? {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Printing')))
                    }
                  : null;
            }
          });
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

class BluePrint {
  BluePrint({this.chunkLen = 512});

  final int chunkLen;
  final _data = List<int>.empty(growable: true);

  void add(List<int> data) {
    _data.addAll(data);
  }

  List<List<int>> getChunks() {
    final chunks = List<List<int>>.empty(growable: true);
    for (var i = 0; i < _data.length; i += chunkLen) {
      chunks.add(_data.sublist(i, min(i + chunkLen, _data.length)));
    }
    return chunks;
  }

  Future<void> printData(BluetoothDevice device) async {
    final data = getChunks();
    final characs = await _getCharacteristics(device);
    for (var i = 0; i < characs.length; i++) {
      if (await _tryPrint(characs[i], data)) {
        break;
      }
    }
  }

  Future<bool> _tryPrint(
    BluetoothCharacteristic charac,
    List<List<int>> data,
  ) async {
    for (var i = 0; i < data.length; i++) {
      try {
        await charac.write(data[i]);
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<List<BluetoothCharacteristic>> _getCharacteristics(
    BluetoothDevice device,
  ) async {
    final services = await device.discoverServices();
    final res = List<BluetoothCharacteristic>.empty(growable: true);
    for (var i = 0; i < services.length; i++) {
      res.addAll(services[i].characteristics);
    }
    return res;
  }
}
