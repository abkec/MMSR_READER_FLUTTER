import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reader_mmsr/localdatabase/Database.dart';

//Edit profile details

class EditProfile extends StatefulWidget{
  List parentData;
  @override
  EditProfile({Key key,this.parentData}) : super(key:key);
  _EditProfile_State createState() => new _EditProfile_State();
}
// ignore: camel_case_types
class _EditProfile_State extends State<EditProfile> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController name,username,email;
  String gender_value;
  static const String MIN_DATETIME = '1950-01-01';
  static const String MAX_DATETIME = '2000-12-31';
  static const String INIT_DATETIME = '1950-01-01';
  String BirthDate;
  DateTime _dateTime;
  String _format = 'yyyy-MM-dd';
  String DOB_text ;
  int groupValue;
  String url = 'http://10.0.2.2/mmsr/';

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    name = new TextEditingController(text: widget.parentData[0].parent_name);
    username = new TextEditingController(text: widget.parentData[0].username);
    email = new TextEditingController(text: widget.parentData[0].parent_email);
    DOB_text = widget.parentData[0].parent_DOB;
    gender_value = widget.parentData[0].parent_gender;
    if(gender_value == 'M')
      {
        radioOnchange(1);
      }
    else
      radioOnchange(2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Edit Profile',style:TextStyle(fontFamily: "WorkSansBold")),automaticallyImplyLeading: false,backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            child: FlatButton(
              onPressed: ()
              {
                updateDetails();
              },
              child: Text('Done',style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18,color: Colors.lightGreenAccent)),
            ),
          ),
        ],),
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
            child: _edit(context),
          ),
        ),
      ),
    );
  }
  Widget _edit(BuildContext context)
  {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10,top: 20),
            alignment: Alignment.centerLeft,
            child: Text('Name',style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20,)),
          ),
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child: TextField(
                controller: name,
                style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18)
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 10,top: 10),
            alignment: Alignment.centerLeft,
            child: Text('Email',style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20,)),
          ),
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child: TextField(
                controller: email,
                style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18)
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10,top: 10),
            alignment: Alignment.centerLeft,
            child: Text('Date of Birth',style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20,)),
          ),
          GestureDetector(
            onTap: ()
            {
              _showDatePicker();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0, right: 10.0,bottom: 10,top: 10),
              child: Text(
                '$DOB_text',
                style: TextStyle(
                    fontFamily: "WorkSansMedium",fontSize: 18),

              ),
            ),
          ),
          Container(
            color: Colors.blueGrey,
            padding: EdgeInsets.only(left: 10,right:10),
            width: 395,
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(left: 10,top: 10),
            alignment: Alignment.centerLeft,
            child: Text('Gender',style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20,)),
          ),
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child: Row(
              children: <Widget>[
                Radio(value: 1, groupValue: groupValue, onChanged:(e)=>radioOnchange(e),activeColor: Colors.blue,),
                Text('Male',style: TextStyle(
                    fontFamily: "WorkSansMedium",fontSize: 18)),
                Radio(value: 2, groupValue: groupValue, onChanged:(e)=>radioOnchange(e),activeColor: Colors.red),
                Text('Female',style: TextStyle(
                    fontFamily: "WorkSansMedium",fontSize: 18)),
              ],
            ),
          ),
          Container(
            color: Colors.blueGrey,
            padding: EdgeInsets.only(left: 10,right:10),
            width: 395,
            height: 1,
          ),
        ],
      ),
    );
  }
  void radioOnchange(int e)//for radio button
  {
    setState(() {
      if(e == 1)
      {
        groupValue = 1;
      }
      else if (e == 2)
      {
        groupValue = 2;
      }
    });

  }
  void updateDetails() async
  {
    final prefs = await SharedPreferences.getInstance();
    var target = prefs.getString('loginID');
    String gender;
    if(groupValue==1)
      {
        gender = 'M';
      }
    else if(groupValue ==2)
      {
        gender = 'F';
      }
//pass data to php file to update details
        http.post(url+"updateParent(Reader).php",
            body: {
              'target':target,
              'parent_name': name.text,
              'parent_gender': gender,
              'parent_email': email.text,
              'parent_DOB': DOB_text,
            });
    var db = DBHelper();
    var parent = Parent(target,widget.parentData[0].password,name.text,email.text,gender,DOB_text);
    db.updateParent(parent);//update in local database
        Navigator.of(context).pop();

  }
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        cancel: Text('custom cancel', style: TextStyle(color: Colors.white)),
      ),
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.parse(MAX_DATETIME),
      initialDateTime: _dateTime,
      dateFormat: _format,
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
          DOB_text = _dateTime.year.toString() +'-'+_dateTime.month.toString().padLeft(2, '0') +'-'+_dateTime.day.toString().padLeft(2,'0');
        });
      },
    );
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
  void BlueSnackBar(String value) {
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
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }
}
