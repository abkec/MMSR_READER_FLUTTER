import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//This is the page to change children account date of birth

class ChangeChildDOB extends StatefulWidget{
  List childData;
  @override
  ChangeChildDOB({Key key, this.childData}) : super(key:key);
  _ChangeChildDOB_State createState() => new _ChangeChildDOB_State();
}
// ignore: camel_case_types
class _ChangeChildDOB_State extends State<ChangeChildDOB> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String DOB_text = "";
  String url = 'http://10.0.2.2/mmsr/';

  static const String MIN_DATETIME = '2005-01-01';
  static const String MAX_DATETIME = '2018-12-31';
  String BirthDate='';
  static const String INIT_DATETIME = '2005-01-01';
  DateTime _dateTime;
  String _format = 'yyyy-MM-dd';
  @override
  void initState() {
    super.initState();
    DOB_text = widget.childData[0].children_DOB;//widget.childData is the object of _ChangeChildDOB_State
                                                //the data of object has only 1, and it is passed by previous page
   // _dateTime=DateTime.parse(widget.childData[0].children_DOB);
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Update BirthDate',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            child: FlatButton(
              onPressed: ()
              {
                updateDOB();
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

  Widget _changeUsername(BuildContext context) //should rename to "_updateChildDOB"
  {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left:10,right: 10, top: 5,bottom: 5),
          color: Colors.white,
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                height: 45,
                color: Colors.white,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 5.0, left: 17.0, right: 25.0),
                      child: Text(
                        '$DOB_text',
                        style: TextStyle(
                            fontFamily: "WorkSansSemiBold",
                            fontSize: 16.0,),
                      ),
                    )
                  ],
                ),
              ),
            )
        ),
      ],
    );
  }
  void updateDOB()async
  {
    BirthDate = _dateTime.year.toString()+'-'+_dateTime.month.toString()+'-'+_dateTime.day.toString();

    //post data to php file
    http.post(url+"updateChildren(Reader).php",body: {
      'children_name':widget.childData[0].children_name,//reuse unchanged details
      'children_DOB':BirthDate,
      'children_gender':widget.childData[0].children_gender,//reuse unchanged details
      'children_image':widget.childData[0].children_image,//reuse unchanged details
      'children_id': widget.childData[0].children_id//reuse unchanged details
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');//parent username
    var db = DBHelper();
    var children = Children(widget.childData[0].children_id,loginID,widget.childData[0].children_name,BirthDate,widget.childData[0].children_gender,widget.childData[0].children_image);
    db.updateChildren(children);//update in local database
    showInSnackBar('Success');
  }
  void showInSnackBar(String value) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      message: value,
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),

    )..show(context).then((r)=> Navigator.pop(context));
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

}
