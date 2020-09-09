import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reader_mmsr/parent_ui/parental_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'parental_gate.dart';

//This page is not using, because of some reason

class ChangeUsername extends StatefulWidget{
  List parentData,childData;
  @override
  ChangeUsername({Key key,this.parentData, this.childData}) : super(key:key);
  _ChangeUsername_State createState() => new _ChangeUsername_State();
}
// ignore: camel_case_types
class _ChangeUsername_State extends State<ChangeUsername> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController usernameField = new TextEditingController();
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Edit Username',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            child: FlatButton(
              onPressed: ()
              {
                updateUsername();
              },
              child: Text('Done',style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18,color: Colors.lightGreenAccent)),
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
            height:  MediaQuery.of(context).size.height,
            child:_changeUsername(context),
          ),
        ),
      ),
    );
  }
  Widget _changeUsername(BuildContext context)
  {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left:10,right: 10, top: 5,bottom: 5),
          color: Colors.white,
          child: TextField(
            controller:  usernameField,
            style: TextStyle(
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
            decoration: InputDecoration(
              hintText: 'Enter New Username',
              hintStyle:  TextStyle( fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
            ),
          ),
        )
      ],
    );
  }
  void updateUsername()async
  {
    var db = DBHelper();
    final response =await http.post(url+"username_register(Reader).php",
        body: {
          "username": usernameField.text,
        });
    var datauser = json.decode(response.body);
    if(datauser.length==0)
      {
        final prefs = await SharedPreferences.getInstance();
        var loginID = prefs.getString('loginID');

        final response2 = await http.post(url+"childrenList(Reader).php",
            body: {
              'parent_username': loginID,
            });
        var datauser2 = json.decode(response2.body);
        if(datauser2.length>0)
          {
            for(int i =0;i<datauser2.length;i++)
            {
              var children = Children(widget.childData[i].children_id,usernameField.text,widget.childData[i].children_name,widget.childData[i].children_DOB
                  ,widget.childData[i].children_gender,widget.childData[i].children_image);
              db.updateChildren(children);
            }
          }

        http.post(url+"updateParentUsername(Reader).php",
            body: {
              'target': loginID,
              'parent_username': usernameField.text,
            });


        var parent = Parent(usernameField.text,widget.parentData[0].password,widget.parentData[0].parent_name,
            widget.parentData[0].parent_gender,widget.parentData[0].parent_email,widget.parentData[0].parent_DOB);
        db.updateParent(parent);
        setState(() {
          prefs.setString('loginID', usernameField.text);

        });
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          message: "Successful Changed",
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),

        )..show(context).then((r)=> Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context)=> Load()),(Route<dynamic> route) => false).then((r){
            setState(() {

            });
        }),);

            }
    else{
      showInSnackBar('Username Used');
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
}
