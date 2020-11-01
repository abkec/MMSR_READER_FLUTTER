import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'dart:io';

//Change password page
//Edit user details can reference Writer Module

class ChangePassword extends StatefulWidget {
  List parentData;
  @override
  ChangePassword({Key key, this.parentData}) : super(key: key);
  _ChangePassword_State createState() => new _ChangePassword_State();
}

// ignore: camel_case_types
class _ChangePassword_State extends State<ChangePassword>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController OldPW = new TextEditingController();
  TextEditingController NewPW = new TextEditingController();
  TextEditingController ConfirmPW = new TextEditingController();
  bool _obscureTextOld = true;
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;
  String url = 'http://10.0.2.2/mmsr/';

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Change Password',
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
                  updatePassword();
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
            child: _changePassword(context),
          ),
        ),
      ),
    );
  }

  Widget _changePassword(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          color: Colors.white,
          child: TextField(
            controller: OldPW,
            style: TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
            obscureText: _obscureTextOld,
            decoration: InputDecoration(
              hintText: "Old Password",
              hintStyle:
                  TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
              suffixIcon: GestureDetector(
                onTap: _toggleOld,
                child: Icon(
                  _obscureTextOld
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          color: Colors.white,
          child: TextField(
            controller: NewPW,
            style: TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
            obscureText: _obscureTextNew,
            decoration: InputDecoration(
              hintText: "New Password",
              hintStyle:
                  TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
              suffixIcon: GestureDetector(
                onTap: _toggleNew,
                child: Icon(
                  _obscureTextNew
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          color: Colors.white,
          child: TextField(
            controller: ConfirmPW,
            style: TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
            obscureText: _obscureTextConfirm,
            decoration: InputDecoration(
              hintText: "Confirm Password",
              hintStyle:
                  TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
              suffixIcon: GestureDetector(
                onTap: _toggleConfirm,
                child: Icon(
                  _obscureTextConfirm
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void updatePassword() async {
    final response = await http.post(url + "getParent(Reader).php", body: {
      "parent_username": widget.parentData[0].username,
    }); //get user data from server
    var datauser = json.decode(response.body);
    if (OldPW.text == '' && NewPW.text == '' && ConfirmPW == '') {
      showInSnackBar("Fill in all the Boxes");
    }
    if (OldPW.text == datauser[0]['parent_password']) {
      //if the old password input by user has matched with password retrieve from server
      //print(datauser[0]['parent_password']);
      if (NewPW.text == ConfirmPW.text) {
        print(ConfirmPW.text);
        //pass data to php file and update data in server
        http.post(url + "updateParentPassword(Reader).php", body: {
          'parent_password': ConfirmPW.text,
          'target': widget.parentData[0].username,
        });

        String desc;
        if (widget.parentData[0].parent_gender == 'M')
          desc = widget.parentData[0].username +
              ' has changed his account password';
        else
          desc = widget.parentData[0].username +
              ' has changed her account password';

        http.post(url + "addLogParent(Reader).php", body: {
          'parent_username': widget.parentData[0].username,
          'title': 'Change Account Password',
          'description': desc,
        });
        var db = DBHelper();
        var parent = Parent(
            widget.parentData[0].username,
            ConfirmPW.text,
            widget.parentData[0].parent_name,
            widget.parentData[0].parent_email,
            widget.parentData[0].parent_gender,
            widget.parentData[0].parent_DOB);
        db.updateParent(parent); //update data in local database
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          message: "Successful Changed",
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        )..show(context).then((r) => Navigator.pop(context));
      } else {
        showInSnackBar('Wrong Confirm Password');
      }
    } else {
      print("OLD:" + datauser[0]['parent_password']);
      showInSnackBar('Wrong Old Password');
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  void _toggleOld() {
    setState(() {
      _obscureTextOld = !_obscureTextOld;
    });
  }

  void _toggleNew() {
    setState(() {
      _obscureTextNew = !_obscureTextNew;
    });
  }

  void _toggleConfirm() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }
}
