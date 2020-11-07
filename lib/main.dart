import 'package:flutter/material.dart';
import 'package:reader_mmsr/ui/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'parent_ui/parental_gate.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> main() async {
  final prefs = await SharedPreferences.getInstance();
  var loginID = prefs.getString('loginID');

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      if (loginID != null) {
        http.post('http://i2hub.tarc.edu.my:8887/mmsr/' + "addLogParent(Reader).php", body: {
          'parent_username': loginID,
          'title': 'Story Reader App Opened',
          'description': loginID + ' has opened the application',
        });
      }
    }
  } on SocketException catch (_) {}

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,

      //if the shared preferences has data then proceed to homepage
      home: loginID == null ? LoginPage() : Load()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: new LoginPage(),
    );
  }
}
