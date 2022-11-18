import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class ApiHelper {

  var toekngeturl="http://88.99.28.142:1728/api/WebAPI/GetToken";

  Future GetToken()async{
    var response= await http.get(Uri.parse(toekngeturl));
    return jsonDecode(response.body);
  }
}