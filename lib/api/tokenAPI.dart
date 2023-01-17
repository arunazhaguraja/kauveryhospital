import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class ApiHelper {

  var toekngeturl="http://signalr.timesmed.com/api/webapi/GetTokens";

  Future GetToken()async{
    var response= await http.get(Uri.parse(toekngeturl));
    Map<String, dynamic> responseJson = json.decode(response.body);
    print(responseJson['Data']);
   // print(jsonDecode(response.body));
    return responseJson['Data'];
  }
}