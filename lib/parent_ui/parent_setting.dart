import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reader_mmsr/parent_ui/change_password.dart';
import 'package:reader_mmsr/parent_ui/parental_gate.dart';
import 'help.dart';
import 'parent_account.dart';
import 'children_account.dart';
import 'change_username.dart';
import 'change_password.dart';
import 'package:url_launcher/url_launcher.dart';
//Settings page


class ParentSettings extends StatefulWidget{
  List childData,parentData;
  @override
  ParentSettings({Key key, this.childData, this.parentData}) : super(key:key);
  _ParentalSettings_State createState() => new _ParentalSettings_State();
}
// ignore: camel_case_types
class _ParentalSettings_State extends State<ParentSettings> with SingleTickerProviderStateMixin {
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
      appBar: new AppBar(title: new Text('Parental Settings',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue, leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> Load()), (Route<dynamic> route) => false);

            },
          );
        },
      ),),
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
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=> LoadProfile()));
            },
            child: ListTile(
              leading: Icon(FontAwesomeIcons.userAlt),
              title: Text('Edit Profile',style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            onTap: ()async{
              bool connection=false;
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  connection=true;
                }
              } on SocketException catch (_) {
                connection=false;
              }
              print(connection);
              if(connection == true)
              {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> ChangePassword(parentData:widget.parentData)),);
              }
              else if(connection == false)
              {
                showInSnackBar('No internet connection');
              }

            },
            child: ListTile(
              leading: Icon(FontAwesomeIcons.lock),
              title: Text('Change Password',style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            child: ListTile(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> ChildrenAccount(childData:widget.childData, parentData:widget.parentData)),);
              },
              leading: Icon(FontAwesomeIcons.users),
              title: Text("Manage Children Account",style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            child: ListTile(
              onTap: ()async{
                String url ='https://forms.gle/U56qKdUHTDd5gJ7i9';
                if (await canLaunch(url)) {
                await launch(url);
                } else {
                showInSnackBar("No Internet Connection");
                }
              },
              leading: Icon(Icons.feedback),
              title: Text("Feedback",style:TextStyle(fontFamily: "WorkSansMedium"
              )),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          GestureDetector(
            child: ListTile(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> Help(),));
              },
              leading: Icon(Icons.help),
              title: Text("Help",style:TextStyle(fontFamily: "WorkSansMedium"
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
