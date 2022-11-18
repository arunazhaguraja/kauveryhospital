
import 'package:dotted_border/dotted_border.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../main.dart';
import '../utlity/blue_print.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

class PrintingWidget extends StatefulWidget {
  final currenttoken;
  const PrintingWidget({Key? key,this.currenttoken}) : super(key: key);

  @override
  _PrintingWidgetState createState() => _PrintingWidgetState();
}

class _PrintingWidgetState extends State<PrintingWidget> {
  List<ScanResult>? scanResult;

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

  void printWithDevice(BluetoothDevice device) async {
    await device.connect();
    final gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
    final printer = BluePrint();

    printer.add(gen.text(widget.currenttoken.toString(),styles: PosStyles(height: PosTextSize.size5)));
    //printer.add(gen.qrcode('${widget.currenttoken} ${now.toString()}',),);
    printer.add(gen.barcode(Barcode.code39(['${widget.currenttoken} ${now.toString()}'])));
    printer.add(gen.text('${widget.currenttoken} ${now.toString()}',),);
    //printer.add(gen.feed(1));
    await printer.printData(device);
    device.disconnect();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>Main()));
  }
  final now = DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
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
                SizedBox(
                  height: 10,
                ),
                Text("Select Printer Device to print",style: TextStyle(color:Color(0xffc01c7b)),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color:Color(0xffc01c7b)),
                    ),
                    height: 300,
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(scanResult![index].device.name),
                          subtitle: Text(scanResult![index].device.id.id),
                          onTap: () => printWithDevice(scanResult![index].device),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: scanResult?.length ?? 0,
                    ),
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
