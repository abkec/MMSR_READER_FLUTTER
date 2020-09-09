import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/Model/LanguagePreferredModel.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:reader_mmsr/utils/bubble_indication_painter.dart';
import 'package:reader_mmsr/parent_ui/parental_gate.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';

//Login and Register Page
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  static const String MIN_DATETIME = '1950-01-01';
  static const String MAX_DATETIME = '2000-12-31';
  static const String INIT_DATETIME = '1950-01-01';
  DateTime _dateTime;
  String _format = 'yyyy-MM-dd';
  String BirthDate = '';

  //Display snackbar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupUsernameController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();
  TextEditingController monthController = new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  String url = 'http://10.0.2.2/mmsr/';

  //For localhost database:
  //  String url = 'http://10.0.2.2/mmsr/';

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
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
            height: MediaQuery.of(context).size.height >= 650.0
                ? MediaQuery.of(context).size.height
                : 2000.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: new Image(
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                      image: new AssetImage('assets/img/mmsr_reader_logo.png')),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 015.0),
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    //red snackbar
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

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Login",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Register",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 150.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: usernameController,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "Username",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 5.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: passwordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 130.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.Colors.buttonGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 10.0,
                    ),
                    BoxShadow(
                      color: Theme.Colors.buttonGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 10.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.buttonGradientEnd,
                        Theme.Colors.buttonGradientStart
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Theme.Colors.buttonGradientEnd,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 42.0),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: "WorkSansBold"),
                    ),
                  ),
                  onPressed: () {
                    _login();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String DOB_text = "Birthdate";
  String textColor = 'black54';
  int groupValue;
  int radioOnchange(int e) {
    setState(() {
      if (e == 1) {
        groupValue = 1;
      } else if (e == 2) {
        groupValue = 2;
      }
    });
    return groupValue;
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                margin: EdgeInsets.only(left: 5),
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 375.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5.0, bottom: 0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeName,
                          controller: signupUsernameController,
                          keyboardType: TextInputType.text,
                          //textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.account_circle,
                              color: Colors.black,
                            ),
                            hintText: "Username",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5.0, bottom: 0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextSignup
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
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5.0, bottom: 0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Confirmation",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _obscureTextSignupConfirm
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
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hintText: "Full Name",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0, left: 25.0, right: 0),
                          child: Container(
                            height: 45,
                            child: Row(
                              children: <Widget>[
                                Icon(FontAwesomeIcons.transgender),
                                Row(
                                  children: <Widget>[
                                    new Radio(
                                      onChanged: (e) => radioOnchange(e),
                                      activeColor: Colors.blue,
                                      value: 1,
                                      groupValue: groupValue,
                                    ),
                                    new Text(
                                      'Male',
                                      style: TextStyle(
                                          fontFamily: "WorkSansSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black),
                                    ),
                                    new Radio(
                                      onChanged: (e) => radioOnchange(e),
                                      activeColor: Colors.red,
                                      value: 2,
                                      groupValue: groupValue,
                                    ),
                                    new Text(
                                      'Female',
                                      style: TextStyle(
                                          fontFamily: "WorkSansSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3.0, bottom: 0, left: 25.0, right: 25.0),
                        child: GestureDetector(
                          onTap: _showDatePicker,
                          child: Container(
                            color: Colors.white,
                            height: 50,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Icon(FontAwesomeIcons.birthdayCake),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                      left: 17.0,
                                      right: 25.0),
                                  child: Text(
                                    '$DOB_text',
                                    style: TextStyle(
                                        fontFamily: "WorkSansSemiBold",
                                        fontSize: 17.0,
                                        color: setColor(DOB_text)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5.0, bottom: 0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                            ),
                            hintText: "Email Address",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 350.0, left: 48),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.Colors.buttonGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 10.0,
                    ),
                    BoxShadow(
                      color: Theme.Colors.buttonGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 10.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.buttonGradientEnd,
                        Theme.Colors.buttonGradientStart
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Theme.Colors.buttonGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () => _signUp()),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 211, left: 110),
              //   child: Text(
              //     'Male',
              //     style: TextStyle(
              //         fontFamily: "WorkSansSemiBold",
              //         fontSize: 16.0,
              //         color: Colors.black),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(top: 211, left: 192),
              //   child: Text(
              //     'Female',
              //     style: TextStyle(
              //         fontFamily: "WorkSansSemiBold",
              //         fontSize: 16.0,
              //         color: Colors.black),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Color setColor(String DOBText) //Set text color
  {
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

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  Future<List> _login() async //login function
  {
  
    if (usernameController.text == "" || passwordController.text == "") {
      showInSnackBar("Fill in All Boxes");
    } else {
      //pass data to php file and retrieve data
      final response = await http.post(url + "login(Reader).php", body: {
        "parent_username": usernameController.text,
        "parent_password": passwordController.text
      });
      var datauser = json.decode(response.body);
      if (datauser.length ==
          0) // if the username and password isn't match in the server
      {
        showInSnackBar("Wrong Username or Password");
      } else {
        //if successfully login, save username in shared preferences
        //in order to keep user login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'loginID',
            datauser[0][
                'parent_username']); //username are unique, the data retrieve from server must only have single row of data
        var loginID = prefs.getString('loginID');
        final response = await http.post(url + "getParent(Reader).php", body: {
          "parent_username": loginID,
        });
        datauser = json.decode(response.body);
        var db = DBHelper();
        var parent = Parent(
            datauser[0]['parent_username'],
            datauser[0]['parent_password'],
            datauser[0]['parent_name'],
            datauser[0]['parent_email'],
            datauser[0]['parent_gender'],
            datauser[0]['parent_DOB']);
        //save user data into local database
        //db.deleteParent("111");

        db.saveParent(parent);
        
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Load()),
        );
        //pushReplacement to disallow user back to login page directly

      }
      return datauser;
    }
  }

  void _showDatePicker() {
    //scrolling list of date to let user select
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

  Future<List> _signUp() async {
    String parent_gender;
    if (signupUsernameController.text == "" ||
        signupEmailController.text == "" ||
        signupPasswordController.text == "" ||
        signupEmailController.text == "" ||
        signupNameController.text == "" ||
        parent_gender == "") {
      showInSnackBar("Fill in All Boxes");
    } else {
      //BirthDate is selected by user
      BirthDate = _dateTime.year.toString() +
          '-' +
          _dateTime.month.toString() +
          '-' +
          _dateTime.day.toString();
      print(BirthDate);
      if (groupValue == 1) {
        parent_gender = 'M';
      } else {
        parent_gender = 'F';
      }

      final response =
          await http.post(url + "username_register(Reader).php", body: {
        "parent_username": signupUsernameController.text,
      });
      var datauser = json.decode(response.body);
      final response2 =
          await http.post(url + "email_register(Reader).php", body: {
        "email": signupEmailController.text,
      });
      var emailData = json.decode(response2.body);
      if (datauser.length == 0 &&
          emailData.length ==
              0) //if username and email register by user is not exist in server database
      {
        if (signupConfirmPasswordController.text ==
            signupPasswordController.text) {
          //pass data to php file
          http.post(url + "parent_register(Reader).php", body: {
            "parent_username": signupUsernameController.text,
            "parent_password": signupPasswordController.text,
            "parent_email": signupEmailController.text,
            "parent_DOB": BirthDate,
            "parent_name": signupNameController.text,
            "parent_gender": parent_gender,
          });
          signupUsernameController.text = "";
          signupPasswordController.text = "";
          signupNameController.text = "";
          signupEmailController.text = "";
          signupConfirmPasswordController.text = "";
          DOB_text = 'Birthdate';
          _onSignInButtonPress();
          BlueSnackBar("Successfull Registered");
        } else {
          showInSnackBar("Wrong Confirm Password");
        }
      } else if (datauser.length > 0) {
        showInSnackBar("Username used!");
      } else {
        showInSnackBar("Email Address used!");
      }
    }
  }
}
