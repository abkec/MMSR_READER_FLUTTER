import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/Model/LanguagePreferredModel.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reader_mmsr/ui/book_list.dart';
import 'package:reader_mmsr/parent_ui/parent_setting.dart';
import 'package:reader_mmsr/ui/login_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import '../ui/edit_children.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//Home page of the app

class Load extends StatefulWidget {
  //load parent Data
  Load({Key key}) : super(key: key);
  @override
  _LoadState createState() => new _LoadState();
}

//State to Load Data
class _LoadState extends State<Load> {
  var db = DBHelper();
  List parentData;
  List childData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    child:Scaffold(
      //extendBodyBehindAppBar: true,

      // appBar: new AppBar(
      //   centerTitle: true,
      //   title: new Text('Parental Gate',
      //       style: TextStyle(fontFamily: 'Avenir',fontWeight: FontWeight.w900, fontSize:30)),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   actions: <Widget>[
      //     Tooltip(
      //       child: IconButton(
      //           icon: Icon(
      //             FontAwesomeIcons.signOutAlt,
      //           ),
      //           onPressed: () async {
      //             SharedPreferences prefs =
      //                 await SharedPreferences.getInstance();
      //             prefs.remove('loginID');
      //             Navigator.of(context).pushAndRemoveUntil(
      //                 MaterialPageRoute(builder: (context) => LoginPage()),
      //                 (Route<dynamic> route) => false);
      //           }),
      //       message: "Log Out",
      //     )
      //   ],
      // ),
      body: new FutureBuilder<List>(
        future: db.getParent(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            parentData = snapshot.data;
            return new FutureBuilder<List>(
              future: db.getChildren(),
              builder: (context, snapshot2) {
                if (snapshot2.hasData) {
                  childData = snapshot2.data;
                  //pass data to second widget
                  return new ParentalGate(
                    parentData: parentData,
                    childData: childData,
                  );
                }
                return SpinKitThreeBounce(color: Colors.blue);
              },
            );
          }
          return SpinKitThreeBounce(color: Colors.blue);
        },
      ),
     ) );
  }
} //load children data

class ParentalGate extends StatefulWidget {
  List parentData;
  List childData;
  @override
  ParentalGate({Key key, this.parentData, this.childData}) : super(key: key);
  _ParentalGate_State createState() => new _ParentalGate_State();
}

// ignore: camel_case_types
class _ParentalGate_State extends State<ParentalGate>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var languageData;

  final PageController childPage = PageController(viewportFraction: 0.8);
  TextEditingController passwordController = new TextEditingController();
  String url = 'http://10.0.2.2/mmsr/';
  bool connection = false;
  void checkconnection() async {
    //check whether internet is avaiable
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = true;
        });
      }
    } on SocketException catch (_) {
      connection = false;
    }
  }

  Future<List> getParent() async {
    //retrieve parent detail
    final response = await  http.post(
      url + "getParent(Reader).php",
      body: {"parent_username": widget.parentData[0].username},
    );
    var data = json.decode(response.body);
    var parent = Parent(
        data[0]['parent_username'],
        data[0]['parent_password'],
        data[0]['parent_name'],
        data[0]['parent_email'],
        data[0]['parent_gender'],
        data[0]['parent_DOB']);
    var db = DBHelper();
    db.updateParent(
        parent); //update parent detail if had make changes in other devices
        
    return data;
  }

  Future<List> getLanguage() async {
    //get all available languages in server
    final response = await http.post(
      url + "getLanguage.php",
    );
    languageData = json.decode(response.body);
    return languageData;
  }

  void initState() {
    //set orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    checkconnection();
    getLanguage();
    getParent();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    checkconnection();
    return new Scaffold(
      floatingActionButton: new FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label:
              Text("Children", style: TextStyle(fontFamily: "WorkSansMedium")),
          elevation: 1.0,
          onPressed: () {
            if (connection == true) {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => Center(
                          // Aligns the container to center
                          child: SingleChildScrollView(
                        child: Container(
                          height: 600,
                          alignment: Alignment.center,
                          child: _AddChildren(
                            languageData: languageData,
                            childData: widget.childData,
                          ),
                        ),
                      )));
            } else {
              showInSnackBar("No internet connection");
            }
          }),
      key: _scaffoldKey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
            margin: EdgeInsets.only(top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 10, left: 30, right: 30),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            flex: 9,
                            child: Text('Welcome',
                                style: TextStyle(
                                    letterSpacing: -1.5,
                                    fontFamily: 'SourceSansBold',
                                    color: const Color(0xffffffff),
                                    fontSize: 44)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Tooltip(
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: const Color(0xffffffff),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    var db = DBHelper();
                                    db.deleteParent(prefs.getString('loginID'));
                                    prefs.clear();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                        (Route<dynamic> route) => false);
                                  }),
                              message: "Log Out",
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.parentData[0].parent_name,
                          style: TextStyle(
                            letterSpacing: 1,
                            fontFamily: 'SourceSansLight',
                            fontSize: 25,
                            color: const Color(0xffffffff),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Content
                //_buildParent(context),
                _buildSwiper(context),
                //_buildChildren(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwiper(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      height: 460,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Swiper(
          loop: false,
          itemCount: widget.childData == null ? 1 : widget.childData.length + 1,
          viewportFraction: 0.65,
          scale: 0.5,
          pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Colors.grey,
              activeSize: 15,
              space: 10,
            ),
          ),
          itemBuilder: (context, index) {
            return InkWell(
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      index == 0
                          ? Card(
                              margin: EdgeInsets.only(top: 80),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              color: const Color(0xffe4ff1a),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 90),
                                    Text(
                                      "Parent",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: const Color(0xff47455f),
                                        fontWeight: FontWeight.w900,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) => Center(
                                                    // Aligns the container to center
                                                    child:
                                                        SingleChildScrollView(
                                                  // A simplified version of dialog.
                                                  child: Container(
                                                      child: AlertDialog(
                                                    title: Text(
                                                      'Enter Password',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "WorkSansSemiBold",
                                                          fontSize: 25),
                                                    ),
                                                    content: Form(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Container(
                                                              height: 50,
                                                              width: 300,
                                                              child: TextField(
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      "Login Password",
                                                                  hintStyle: TextStyle(
                                                                      fontFamily:
                                                                          "WorkSansSemiBold",
                                                                      fontSize:
                                                                          17.0),
                                                                ),
                                                                controller:
                                                                    passwordController,
                                                                obscureText:
                                                                    true,
                                                              )),
                                                          Container(
                                                            child: ButtonBar(
                                                              children: <
                                                                  Widget>[
                                                                FlatButton(
                                                                  onPressed:
                                                                      () {
                                                                    passwordController =
                                                                        new TextEditingController(
                                                                            text:
                                                                                '');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'Cancel',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black)),
                                                                ),
                                                                FlatButton(
                                                                    color: Colors
                                                                        .amber,
                                                                    onPressed:
                                                                        () {
                                                                      if (passwordController
                                                                              .text ==
                                                                          "") {
                                                                        passwordController =
                                                                            new TextEditingController(text: '');
                                                                        showInSnackBar(
                                                                            "Enter Password");
                                                                      } else {
                                                                        if (passwordController.text ==
                                                                            widget.parentData[0].password) {
                                                                          passwordController =
                                                                              new TextEditingController(text: '');

                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ParentSettings(childData: widget.childData, parentData: widget.parentData)),
                                                                          );
                                                                        } else {
                                                                          passwordController =
                                                                              new TextEditingController(text: '');
                                                                          showInSnackBar(
                                                                              'Wrong Password');
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                      'Submit',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ))
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                                )));
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Settings',
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                  238, 76, 124, 1),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color:
                                                Color.fromRGBO(238, 76, 124, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Card(
                              margin: EdgeInsets.only(top: 80),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 90),
                                    Text(
                                      widget.childData[index - 1].children_name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: const Color(0xff47455f),
                                        fontWeight: FontWeight.w900,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Children',
                                      style: TextStyle(
                                        fontFamily: 'Avenir',
                                        fontSize: 23,
                                        color: const Color(0xff47455f),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 30),
                                    GestureDetector(
                                      onTap: () async {
                                        bool connection = false;
                                        try {
                                          final result =
                                              await InternetAddress.lookup(
                                                  'google.com');
                                          if (result.isNotEmpty &&
                                              result[0].rawAddress.isNotEmpty) {
                                            connection = true;
                                          }
                                        } on SocketException catch (_) {
                                          connection = false;
                                        }
                                        print(connection);
                                        if (connection == true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoadChildData(
                                                        childData:
                                                            widget.childData,
                                                        index: index-1)),
                                          );
                                        } else if (connection == false) {
                                          showInSnackBar(
                                              'No internet connection');
                                        }
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                  238, 76, 124, 1),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color:
                                                Color.fromRGBO(238, 76, 124, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoadBook(
                                                  childrenID: widget
                                                      .childData[index-1]
                                                      .children_id)),
                                        );
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Know more',
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                  238, 76, 124, 1),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color:
                                                Color.fromRGBO(238, 76, 124, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                  index == 0
                      ? Container(
                          alignment: Alignment.center,
                          height: 180,
                          child: Image.asset('assets/img/parents.png'),
                        )
                      : Container(
                          alignment: Alignment.center,
                          height: 180,
                          child: Card(
                            elevation: 25,
                            color: Colors.transparent,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(
                                side: BorderSide(color: Colors.grey.shade200)),
                            child: Image.asset(
                                widget.childData[index - 1].children_image),
                          ),
                        ),
                  index == 0
                      ? Container()
                      : Positioned(
                          right: 20,
                          bottom: 55,
                          child: Text(
                            index.toString(),
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 200,
                              color: Color.fromRGBO(1, 1, 1, 0.2),
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildren(BuildContext context) {
    return widget.childData.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/img/empty.png",
                  height: 150,
                ),
                Text(
                  "Press '+ Children' ",
                  style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.only(left: 5),
            width: double.infinity,
            height: 250,
            child: Container(
              alignment: Alignment.center,
              child: ListView.builder(
                //shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                controller: childPage,
                itemCount:
                    widget.childData == null ? 0 : widget.childData.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoadBook(
                                childrenID: widget.childData[i].children_id)),
                      );
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              height: 150,
                              child: Card(
                                elevation: 4,
                                clipBehavior: Clip.antiAlias,
                                shape: CircleBorder(
                                    side: BorderSide(
                                        color: Colors.grey.shade200)),
                                child: Image.asset(
                                    widget.childData[i].children_image),
                              ),
                            ),
                          ],
                        )),
                  );
                },
              ),
            ));
  }
}

class _AddChildren extends StatefulWidget {
  // this is dialog box for create children account in stateful widget
  //create new Statefulwidget for dialog box is needed, else the dialog box will dont have response after user selected some options.
  @override
  List languageData, childData;
  _AddChildren({Key key, this.languageData, this.childData}) : super(key: key);
  AddChildren_State createState() => AddChildren_State();
}

class AddChildren_State extends State<_AddChildren> {
  @override
  String DOB_text = "Birthdate";
  String url = 'http://10.0.2.2/mmsr/';

  static const String MIN_DATETIME = '2005-01-01';
  static const String MAX_DATETIME = '2018-12-31';
  String BirthDate = '';
  static const String INIT_DATETIME = '2005-01-01';
  DateTime _dateTime;
  String _format = 'yyyy-MM-dd';
  Color picColor = Colors.white;
  String textColor = 'black54';
  TextEditingController nameController = new TextEditingController();
  int groupValue;
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
  var checkBox = [];
  @override
  void initState() {
    // TODO: implement initState

    _dateTime = DateTime.parse(INIT_DATETIME);
    super.initState();
  }

  var pickImage = [];
  void
      createValue() //create a list of "false" options for images and languages, if user selected the image, it will change to "true"
  {
    for (int i = 0; i < widget.languageData.length; i++) {
      checkBox.add(false);
    }
    for (int i = 0; i < animals.length; i++) {
      pickImage.add(false);
    }
  }

  Future _submitDetails() async {
    var datauser;
    int child_no = 0;
    final prefs = await SharedPreferences.getInstance();
    var parent_username = prefs.getString('loginID');

    String gender, children_image;

    if (groupValue == 1) {
      gender = 'M';
    } else {
      gender = 'F';
    }
    final response = await http.post(
      url + "getChildren(Reader).php",
    );
    var childrenlength = json.decode(response.body);
    print("length:" + childrenlength.length.toString());
    child_no = childrenlength.length + 1;
    String children_id = 'child' + '_' + child_no.toString().padLeft(2, '0');
    print(children_id);
    for (int i = 0; i < animals.length; i++) {
      if (pickImage[i] == true) {
        children_image = animals[i];
      }
    }
    if (nameController.text != "" &&
        BirthDate != "Birthdate" &&
        gender != "" &&
        children_image != '') {
      BirthDate = _dateTime.year.toString() +
          '-' +
          _dateTime.month.toString() +
          '-' +
          _dateTime.day.toString();
      http.post(url + 'addChildren(Reader).php', body: {
        "children_id": children_id,
        "parent_username": parent_username,
        "children_name": nameController.text,
        "children_DOB": BirthDate,
        "children_gender": gender,
        "children_image": children_image,
      });

      var db = DBHelper();
      var children = Children(children_id, parent_username, nameController.text,
          BirthDate, gender, children_image);

      db.saveChildren(children);

      print(widget.languageData.length);
      for (int i = 0; i < widget.languageData.length; i++) {
        if (checkBox[i] == true) {
          http.post(url + "addLanguagePreferred(Reader).php", body: {
            "children_id": children_id,
            "languageCode": widget.languageData[i]['languageCode'],
          });
          var language = LanguagePreferred(
              children_id, widget.languageData[i]['languageCode']);
          db.saveLanguagePreferred(language);
        }
      }
    }
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

  Color setColor(String DOBText) {
    Color color;
    setState(() {
      if (DOBText == 'Birthdate') {
        color = Colors.black54;
      } else {
        color = Colors.black;
      }
    });
    return color;
  }

  @override
  Widget build(BuildContext context) {
    createValue();
    return SingleChildScrollView(
        child: Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.only(top: 0, left: 25, right: 25),
        title: Text("Add Children Account"),
        content: Form(
          child: Column(
            children: <Widget>[
              Container(
                child: TextField(
                  controller: nameController,
                  style:
                      TextStyle(fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
                  decoration: InputDecoration(
                      icon: Icon(
                        FontAwesomeIcons.child,
                        color: Colors.black,
                      ),
                      hintText: 'Nickname',
                      border: InputBorder.none),
                ),
              ), // Name

              Container(
                height: 1.0,
                color: Colors.grey[400],
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                  child: GestureDetector(
                    onTap: _showDatePicker,
                    child: Container(
                      height: 45,
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.birthdayCake),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 5.0,
                                left: 17.0,
                                right: 25.0),
                            child: Text(
                              '$DOB_text',
                              style: TextStyle(
                                  fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0,
                                  color: setColor(DOB_text)),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),

              Container(
                height: 1.0,
                color: Colors.grey[400],
              ),

              Padding(
                padding: EdgeInsets.only(
                    top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
                child: Row(
                  children: <Widget>[
                    Text('Gender'),
                    Radio(
                      value: 1,
                      groupValue: groupValue,
                      onChanged: (e) => radioOnchange(e),
                      activeColor: Colors.blue,
                    ),
                    Icon(FontAwesomeIcons.male),
                    Radio(
                        value: 2,
                        groupValue: groupValue,
                        onChanged: (e) => radioOnchange(e),
                        activeColor: Colors.red),
                    Icon(FontAwesomeIcons.female),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.topLeft,
                child: Text("Languages you preferred "),
              ),
              Container(
                height: 8.0,
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Card(
                      elevation: 9.0,
                      color: Colors.white,
                      child: Container(
                        width: 300,
                        child: ListView.builder(
                            itemCount: widget.languageData == null
                                ? 0
                                : widget.languageData.length,
                            itemBuilder: (context, i) {
                              return Container(
                                  child: CheckboxListTile(
                                title: Text(
                                    widget.languageData[i]['languageDesc']),
                                value: checkBox[i],
                                onChanged: (bool value) {
                                  setState(() {
                                    checkBox[i] = value;
                                  });
                                },
                              ));
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 8.0,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Text("Pick an image: ",
                    style: TextStyle(fontFamily: 'WorkSansBold', fontSize: 20)),
              ),
              Container(
                height: 8.0,
              ),
              Container(
                  height: 100,
                  width: 300,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: animals.length,
                      itemBuilder: (context, i) {
                        return Container(
                          color: pickImage[i] == false
                              ? Colors.white
                              : Colors.grey,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (pickImage[i] == false) {
                                  pickImage[i] = true;
                                  for (int j = 0;
                                      j != i && j < animals.length;
                                      j++) {
                                    pickImage[j] = false;
                                  }
                                  for (int j = animals.length - 1;
                                      j != i && j >= 0;
                                      j--) {
                                    pickImage[j] = false;
                                  }
                                } else {
                                  pickImage[i] = false;
                                }
                              });
                            },
                            child: Card(
                              elevation: 4,
                              clipBehavior: Clip.antiAlias,
                              shape: CircleBorder(
                                  side:
                                      BorderSide(color: Colors.grey.shade200)),
                              child: Image.asset(
                                animals[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      })),
              Container(
                  child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                  FlatButton(
                      color: Colors.amber,
                      onPressed: () async {
                        _submitDetails();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                                child: Container(
                                    height: 200,
                                    width: 50,
                                    child: new Card(
                                      child: Center(
                                        child: SpinKitThreeBounce(
                                            color: Colors.blue),
                                      ),
                                    )));
                          },
                        );
                        new Future.delayed(new Duration(seconds: 1), () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => Load()),
                              (Route<dynamic> route) => false);
                        });
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              )),
            ],
          ),
        ),
      ),
    ));
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
          DOB_text = _dateTime.year.toString() +
              '-' +
              _dateTime.month.toString().padLeft(2, '0') +
              '-' +
              _dateTime.day.toString().padLeft(2, '0');
        });
      },
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
