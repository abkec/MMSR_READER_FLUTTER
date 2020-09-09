import 'package:flutter/material.dart';
import 'package:reader_mmsr/ui/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'parent_ui/parental_gate.dart';

Future<void> main() async {
  
  final prefs = await SharedPreferences.getInstance();
  var loginID = prefs.getString('loginID');
  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,

        //if the shared preferences has data then proceed to homepage
          home: loginID == null ? LoginPage() : Load())
  );
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
