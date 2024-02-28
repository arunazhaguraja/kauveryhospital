import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class ApiHelper {

  //String toekngeturl="http://signalr.timesmed.com/api/webapi/GetTokens";
  //String toekngeturl='http://testsignalr.timesmed.com//token/generatetoken?deptId=2';
  //Kavery alwarpet prod
  //String toekngeturl='http://signalr.timesmed.com//token/generatetoken?deptId=1';

  //kavery trichy prod
  //String toekngeturl='http://signalr.timesmed.com/token/generatetoken?deptId=2';

  //kavery trichy test
  String toekngeturl='http://testsignalr.timesmed.com//token/generatetoken?deptId=2';



  Future GetToken()async{
    var response= await http.get(Uri.parse(toekngeturl));
    //Map<String, dynamic> responseJson = json.decode(response.body);

    int responseJson = json.decode(response.body);
    //print(responseJson['Data']);
    print(responseJson);
   // print(jsonDecode(response.body));
    return responseJson;
    //return responseJson['Data'];
  }
}