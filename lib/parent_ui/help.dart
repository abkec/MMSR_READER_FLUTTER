import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatefulWidget{
  List childData,parentData;
  @override
  Help({Key key, this.childData, this.parentData}) : super(key:key);
  _Help_State createState() => new _Help_State();
}
// ignore: camel_case_types
class _Help_State extends State<Help> with SingleTickerProviderStateMixin {
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
      appBar: new AppBar(title: new Text('Help',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue),
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
            width: MediaQuery.of(context).size.width,
            height: 600,

            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: _buildSettings(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSettings(BuildContext context)
  {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: ()async{
              String url ='http://i2hub.tarc.edu.my:8887/mmsr/aboutus.php';
              if (await canLaunch(url)) {
              await launch(url);
              } else {
                showInSnackBar("No Internet Connection");
              }
            },
            child: ListTile(
              leading: Icon(FontAwesomeIcons.users),
              title: Text('About Us',style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            onTap: ()async{
              String url ='http://i2hub.tarc.edu.my:8887/mmsr/privacypolicy.php';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Privacy Policy',style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            onTap: ()async{
              String url ='http://i2hub.tarc.edu.my:8887/mmsr/ContactUs/contactus.html';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: ListTile(
              leading: Icon(Icons.contact_phone),
              title: Text('Contact Us',style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),

        ],
      ),
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
}