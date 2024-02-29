import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../Consts/consts.dart';


class ApiHelper {

  //String toekngeturl="http://signalr.timesmed.com/api/webapi/GetTokens";
  //String toekngeturl='http://testsignalr.timesmed.com//token/generatetoken?deptId=2';
  //Kavery alwarpet prod
  //String toekngeturl='http://signalr.timesmed.com//token/generatetoken?deptId=1';

  //kavery trichy prod
  String toekngeturl='http://signalr.timesmed.com/token/generatetoken?deptId=2';

  //kavery trichy test
  //String toekngeturl='http://testsignalr.timesmed.com//token/generatetoken?deptId=2';




  Future getToken(BuildContext context) async {
    try {
      var response = await http.get(Uri.parse(Const.tokenURL));
      int responseJson = json.decode(response.body);
      print(responseJson);
      return responseJson;
    } catch (e) {
      showMaterialBanner(context, "Error: Please check your internet connection and try again.");

      return null; // or throw an exception to handle the error further up the call stack
    }
  }

}

void showMaterialBanner(BuildContext context, String message) {
  final banner = Banner(
    message: message,
    location: BannerLocation.topStart,
    color: Colors.red, // Customize color according to your design
    textStyle: TextStyle(color: Colors.white), // Customize text color
    child: Container(), // This can be an empty container, or you can replace it with any widget
  );

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.showSnackBar(SnackBar(
    content: Text(message,style: TextStyle(color: Colors.white),),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.red,
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Close',
      onPressed: () {
        scaffoldMessenger.hideCurrentSnackBar();
      },
    ),
  ));
}