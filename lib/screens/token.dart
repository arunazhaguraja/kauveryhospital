import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../main.dart';

class Token extends StatefulWidget {
  final currenttoken;

  const Token({Key? key, this.currenttoken}) : super(key: key);

  @override
  State<Token> createState() => _TokenState();
}

class _TokenState extends State<Token> {
  bool connected = false;
  List availableBluetoothDevices = [];

  var imagelocation;

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

  Future<void> printTokenImage(img) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTokenImage(img);
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getTokenImage(img) async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.image(img);

    bytes += generator.cut();

    return bytes;
  }

  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  late File imgFile;

  final snackBar = SnackBar(
    content: Text('Please select the printer device first'),
    duration: Duration(seconds: 3),
  );

  getSetImage() async{
    final directory =
    (await getApplicationDocumentsDirectory()).path;
    imgFile = File('$directory/photo.png');
    Uint8List? pngBytes = await controller.capture();
    await imgFile.writeAsBytes(pngBytes!);
    printTokenImage(imgFile.path);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>Main()));
  }

  final now = DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    this.getBluetooth();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

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
                              value: "${widget.currenttoken} ${now.toString()}",
                              showValue: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // TextButton(
                      //   onPressed: () {
                      //     this.getBluetooth();
                      //   },
                      //   child: Text("Search Paired Bluetooth",style: TextStyle(color:Color(0xffc01c7b)),),
                      // ),
                      Text("Select Printer Device",style: TextStyle(color:Color(0xffc01c7b)),),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Color(0xffc01c7b)),
                        ),
                        height: 200,
                        child: ListView.builder(
                          itemCount: availableBluetoothDevices.length > 0
                              ? availableBluetoothDevices.length
                              : 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                String select =
                                    availableBluetoothDevices[index];
                                List list = select.split("#");
                                // String name = list[0];
                                String mac = list[1];
                                this.setConnect(mac);
                              },
                              title:
                                  Text('${availableBluetoothDevices[index]}'),
                              subtitle: Text("Click to connect"),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // TextButton(
                      //   // onPressed: connected ? this.printGraphics : null,
                      //   onPressed: () async {
                      //     final directory =
                      //         (await getApplicationDocumentsDirectory()).path;
                      //     imgFile = File('$directory/photo.png');
                      //     Uint8List? pngBytes = await controller.capture();
                      //     await imgFile.writeAsBytes(pngBytes!);
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => Imaeg(
                      //                 file: imgFile.path,
                      //               )),
                      //     );
                      //   },
                      //   child: Text("Print"),
                      // ),
                      TextButton.icon(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xffffcf78)),),
                        icon: Icon(Icons.print_outlined,color:Color(0xffc01c7b)),
                        label: Text("Print Token",style: TextStyle(color:Color(0xffc01c7b)),),
                        onPressed: () {
                          connected ? getSetImage() : ScaffoldMessenger.of(context).showSnackBar(snackBar);                        },

                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

class Imaeg extends StatelessWidget {
  final file;

  const Imaeg({Key? key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.file(File(file))));
  }
}
