import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reader_mmsr/ui/edit_childDOB.dart';
import 'package:reader_mmsr/ui/edit_childName.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_childName.dart';
import 'edit_childGender.dart';
import 'edit_childDOB.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'dart:io';
//Edit Children account Menu page

//Retrieve data from local and server database
class LoadChildData extends StatefulWidget {
  List childData;
  int index;
  LoadChildData({Key key, this.childData, this.index}) : super(key: key);
  @override
  _LoadChildDataState createState() => new _LoadChildDataState();
}

class _LoadChildDataState extends State<LoadChildData> {
  var db = DBHelper();
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Children Profile',
              style: TextStyle(fontFamily: "WorkSansBold")),
          backgroundColor: Colors.lightBlue),
      body: new FutureBuilder<List>(
        future: db.getChildrenByID(widget.childData[widget.index]
            .children_id), //start with "db.", data retrieve from local database. "widget.childData" is object of _LoadChildDataState
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              //pass to next load
              ? new EditChildrenAccount(
                  childData: snapshot.data,
                )
              : new Center(
                  child: new CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

class EditChildrenAccount extends StatefulWidget {
  List childData;
  @override
  EditChildrenAccount({Key key, this.childData}) : super(key: key);
  _EditChildrenAccount_State createState() => new _EditChildrenAccount_State();
}

// ignore: camel_case_types
class _EditChildrenAccount_State extends State<EditChildrenAccount>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
            child: _buildAccount(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAccount(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(FontAwesomeIcons.child),
            title: Text(
              "Name",
              style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChangeChildName(childData: widget.childData)),
              );
            },
            subtitle: Text(widget.childData[0].children_name,
                style: TextStyle(fontSize: 18, fontFamily: "WorkSansMedium")),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.birthdayCake),
            title: Text(
              'Birthdate',
              style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
            ),
            subtitle: Text(widget.childData[0].children_DOB,
                style: TextStyle(fontSize: 18, fontFamily: "WorkSansMedium")),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChangeChildDOB(childData: widget.childData)),
              );
            },
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            leading: widget.childData[0].children_gender == 'M'
                ? Icon(FontAwesomeIcons.male)
                : Icon(FontAwesomeIcons.female),
            title: Text(
              'Gender',
              style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
            ),
            subtitle: widget.childData[0].children_gender == 'M'
                ? Text('Boy',
                    style:
                        TextStyle(fontSize: 18, fontFamily: "WorkSansMedium"))
                : Text('Girl',
                    style:
                        TextStyle(fontSize: 18, fontFamily: "WorkSansMedium")),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChangeChildGender(childData: widget.childData)),
              );
            },
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.solidImage),
            title: Text(
              "Change Profile Picture",
              style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                          // Aligns the container to center
                          child: SingleChildScrollView(
                        // A simplified version of dialog.
                        child: Container(
                          //height: 450,
                          child: ChangeProfilePic(childData: widget.childData),
                        ),
                      )));
            },
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }
}

//Change account picture DIALOG BOX
//this dialog box need to create new StatefulWidget, else the dialog box do not have action when user selected something.
class ChangeProfilePic extends StatefulWidget {
  List childData;
  ChangeProfilePic({Key key, this.childData}) : super(key: key);
  @override
  _ChangeProfilePicState createState() => new _ChangeProfilePicState();
}

class _ChangeProfilePicState extends State<ChangeProfilePic> {
  List<String> animals = [
    'assets/img/bear.png',
    'assets/img/tiger.png',
    'assets/img/frog.png',
    'assets/img/panda.png',
    'assets/img/koala.png',
    'assets/img/monkey.png',
    'assets/img/pig.png',
    'assets/img/cat.png',
    'assets/img/fox.png',
    'assets/img/rabbit.png'
  ];
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  String children_image;
  var pickImage = [];
  void
      createValue() //creating a list of "false". while user picked an image, then it will be "true"
  {
    for (int i = 0; i < animals.length; i++) {
      pickImage.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    createValue();
    return AlertDialog(
      title: Text("Pick an Image"),
      content: Form(
        child: Column(
          children: <Widget>[
            Container(
                height: 100,
                width: 300,
                child: Container(
                    height: 100,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: animals.length,
                        itemBuilder: (context, i) {
                          return Container(
                            color: pickImage[i] == false
                                ? Colors.white
                                : Colors
                                    .grey, //if value is true then become grey background
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (pickImage[i] == false) {
                                    //if the selected picture is false

                                    pickImage[i] =
                                        true; //then change it to true
                                    for (int j = 0;
                                        j != i && j < animals.length;
                                        j++) {
                                      //make sure the rest of the value are false
                                      pickImage[j] = false;
                                    }
                                    for (int j = animals.length - 1;
                                        j != i && j >= 0;
                                        j--) {
                                      //make sure the rest of the value are false
                                      pickImage[j] = false;
                                    }
                                  } else {
                                    //when pressed, if the value is true then change it to false
                                    pickImage[i] = false;
                                  }
                                });
                              },
                              child: Card(
                                elevation: 4,
                                clipBehavior: Clip.antiAlias,
                                shape: CircleBorder(
                                    side: BorderSide(
                                        color: Colors.grey.shade200)),
                                child: Image.asset(
                                  animals[i],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }))),
            Container(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  FlatButton(
                      color: Colors.amber,
                      onPressed: () async {
                        bool connection = false;
                        try {
                          final result =
                              await InternetAddress.lookup('google.com');
                          if (result.isNotEmpty &&
                              result[0].rawAddress.isNotEmpty) {
                            connection = true;
                          }
                        } on SocketException catch (_) {
                          connection = false;
                        }
                        print(connection);
                        if (connection == true) {
                          setState(() {
                            for (int i = 0; i < animals.length; i++) {
                              if (pickImage[i] == true) {
                                children_image = animals[i];
                              }
                            }

                            updateImage();
                            Navigator.of(context).pop();
                          });
                        } else if (connection == false) {
                          showInSnackBar('No internet connection');
                        }
                      },
                      child: Text('Submit'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      message: value,
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    )..show(context).then((r) => Navigator.pop(context));
  }

  void updateImage() async //Children change account picture
  {
    //data pass to php files
    http.post(url + "updateChildren(Reader).php", body: {
      'children_name': widget.childData[0].children_name, //reuse unchanged data
      'children_DOB': widget.childData[0].children_DOB, //reuse unchanged data
      'children_gender':
          widget.childData[0].children_gender, //reuse unchanged data
      'children_image': children_image,
      'children_id': widget.childData[0].children_id //reuse unchanged data
    });
    String desc;
    if (widget.childData[0].children_gender == 'M')
      desc =
          widget.childData[0].children_id + ' has changed his profile picture';
    else
      desc =
          widget.childData[0].children_id + ' has changed her profile picture';

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
        widget.childData[0].children_gender,
        children_image);
    db.updateChildren(children); //update in local database
  }
}
