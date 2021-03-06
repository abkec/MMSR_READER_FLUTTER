import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
//This is the page to change children account name

class ChangeChildName extends StatefulWidget {
  List childData;
  @override
  ChangeChildName({Key key, this.childData}) : super(key: key);
  _ChangeChildName_State createState() => new _ChangeChildName_State();
}

// ignore: camel_case_types
class _ChangeChildName_State extends State<ChangeChildName>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameField = new TextEditingController();
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  @override
  void initState() {
    //set the screen orientation to only potrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    nameField = new TextEditingController(
        text: widget.childData[0]
            .children_name); //widget.childData is the object of _ChangeChildName_State
    //set the name initially for display purpose
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Update Name',
            style: TextStyle(fontFamily: "WorkSansBold")),
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            child: FlatButton(
              onPressed: () async {
                bool connection = false;
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    connection = true;
                  }
                } on SocketException catch (_) {
                  connection = false;
                }
                print(connection);
                if (connection == true) {
                  updateName();
                } else if (connection == false) {
                  showInSnackBar('No internet connection');
                }
              },
              child: Text('Done',
                  style: TextStyle(
                      fontFamily: "WorkSansMedium",
                      fontSize: 18,
                      color: Colors.lightGreenAccent)),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      body: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                Theme.Colors.loginGradientStart,
                Theme.Colors.loginGradientEnd
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _changeUsername(context),
          ),
        ),
      ),
    );
  }

  Widget _changeUsername(
      BuildContext context) //should rename to _changeChildrenName
  {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          color: Colors.white,
          child: TextField(
            controller: nameField,
            style: TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
          ),
        ),
      ],
    );
  }

  void updateName() async // update children account name
  {
    //post details to php file
    http.post(url + "updateChildren(Reader).php", body: {
      'children_name': nameField.text,
      'children_DOB':
          widget.childData[0].children_DOB, //reuse all unchange details
      'children_gender':
          widget.childData[0].children_gender, //reuse all unchange details
      'children_image':
          widget.childData[0].children_image, //reuse all unchange details
      'children_id':
          widget.childData[0].children_id //reuse all unchange details
    });

    String desc;
    if (widget.childData[0].children_gender == 'M')
      desc = widget.childData[0].children_id + ' has changed his name';
    else
      desc = widget.childData[0].children_id + ' has changed her name';

    http.post(url + "addLogChildren(Reader).php", body: {
      'children_id': widget.childData[0].children_id,
      'title': 'Edit Children Account',
      'description': desc,
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    //update in local database
    var db = DBHelper();
    var children = Children(
        widget.childData[0].children_id,
        loginID,
        nameField.text,
        widget.childData[0].children_DOB,
        widget.childData[0].children_gender,
        widget.childData[0].children_image);
    db.updateChildren(children);

    showInSnackBar('Success');
  }

  void showInSnackBar(String value) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      message: value,
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    )..show(context).then((r) => Navigator.pop(context));
  }
}
