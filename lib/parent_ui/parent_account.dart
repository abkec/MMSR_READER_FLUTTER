import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'edit_profile.dart';

//Show parent account detail only

class LoadProfile extends StatefulWidget{
  LoadProfile({Key key}) : super(key: key);
@override
_LoadProfileState createState() => new _LoadProfileState();
}

class _LoadProfileState extends State<LoadProfile> {
  var  db = DBHelper();//local database

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: new FutureBuilder<List>(
        future: db.getParent(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
          //pass to next load
              ? new ParentAccount(
            parentData: snapshot.data,
          )
              : new Center(
                child: new CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}


class ParentAccount extends StatefulWidget{
  List parentData;
  @override
  ParentAccount({Key key,this.parentData}) : super(key:key);
  _ParentalAccount_State createState() => new _ParentalAccount_State();
}
// ignore: camel_case_types
class _ParentalAccount_State extends State<ParentAccount> with SingleTickerProviderStateMixin {
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
      appBar: new AppBar(title: new Text('Profile',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue,
      actions: <Widget>[
        new Container(
          alignment: Alignment.center,
          child: FlatButton(
            onPressed: ()async
            {
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
                    MaterialPageRoute(builder: (context)=> EditProfile(parentData:widget.parentData)),);
                }
              else if(connection == false)
                {
                  showInSnackBar('No internet connection');
                }
            },
            child: Text('Edit',style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18,color: Colors.white)),
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
            child: _buildAccount(context),
          ),
        ),
      ),
    );
  }
  Widget _buildAccount(BuildContext context)
  {
    return Container(
      child: Column(
        children: <Widget>[

            ListTile(
              leading: Icon(FontAwesomeIcons.userCheck),
              title: Text("Name",style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20),),
              subtitle: Text(widget.parentData[0].parent_name,style: TextStyle(fontSize: 18,fontFamily: "WorkSansMedium"),),
            ),

             ListTile(
              leading: Icon(Icons.mail),
              title: Text("Email",style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20),),
              subtitle: Text(widget.parentData[0].parent_email,style: TextStyle(fontSize: 18,fontFamily: "WorkSansMedium"),),
            ),

             ListTile(
              leading: Icon(FontAwesomeIcons.birthdayCake),
              title: Text("Date Of Birth",style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20),),
              subtitle: Text(widget.parentData[0].parent_DOB,style: TextStyle(fontSize: 18,fontFamily: "WorkSansMedium"),),
            ),

             ListTile(
              leading: Icon(FontAwesomeIcons.transgender),
              title: Text("Gender",style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20),),
              subtitle: Text(widget.parentData[0].parent_gender,style: TextStyle(fontSize: 18,fontFamily: "WorkSansMedium"),),
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
