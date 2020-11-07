import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

//This page is to change children account gender

class ChangeChildGender extends StatefulWidget {
  List childData;
  @override
  ChangeChildGender({Key key, this.childData}) : super(key: key);
  //first, get children account details from previous page.
  //"this.childData" has stored the details of the children account.
  _ChangeChildGender_State createState() => new _ChangeChildGender_State();
}

// ignore: camel_case_types
class _ChangeChildGender_State extends State<ChangeChildGender>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int groupValue;
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  @override
  void initState() {
    if (widget.childData[0].children_gender ==
        'M') //widget.childData[0] is the object from _ChangeChildrenGender_State
    //in the object will have only 1 data.
    {
      groupValue = 1;
    } else {
      groupValue = 2;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Update Gender',
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
                  updateGender();
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

  void radioOnchange(int e) {
    setState(() {
      if (e == 1) {
        groupValue = 1;
      } else if (e == 2) {
        groupValue = 2;
      }
    });
  }

  Widget _changeUsername(
      BuildContext context) // should rename to _updateChildGender
  {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Text(
                'Gender',
                style: TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 18),
              ),
              Radio(
                value: 1,
                groupValue: groupValue,
                onChanged: (e) => radioOnchange(e),
                activeColor: Colors.blue,
              ),
              Icon(FontAwesomeIcons.male),
              Text('Boy',
                  style:
                      TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 18)),
              Radio(
                  value: 2,
                  groupValue: groupValue,
                  onChanged: (e) => radioOnchange(e),
                  activeColor: Colors.red),
              Icon(FontAwesomeIcons.female),
              Text('Girl',
                  style:
                      TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  void updateGender() async {
    String gender;
    if (groupValue == 1) {
      gender = 'M';
    } else
      gender = 'F';

    //post data to php file
    http.post(url + "updateChildren(Reader).php", body: {
      'children_name':
          widget.childData[0].children_name, //reuse all unchanged details
      'children_DOB':
          widget.childData[0].children_DOB, //reuse all unchanged details
      'children_gender': gender,
      'children_image':
          widget.childData[0].children_image, //reuse all unchanged details
      'children_id':
          widget.childData[0].children_id //reuse all unchanged details
    });
    String desc;
    if (widget.childData[0].children_gender == 'M')
      desc = widget.childData[0].children_id + ' has changed his gender';
    else
      desc = widget.childData[0].children_id + ' has changed her gender';

    http.post(url + "addLogChildren(Reader).php", body: {
      'children_id': widget.childData[0].children_id,
      'title': 'Edit Children Account',
      'description': desc,
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    var db = DBHelper();
    var children = Children(
        widget.childData[0].children_id,
        loginID,
        widget.childData[0].children_name,
        widget.childData[0].children_DOB,
        gender,
        widget.childData[0].children_image);

    db.updateChildren(children); //update in local database
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
