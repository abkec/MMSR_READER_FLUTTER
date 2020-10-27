import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reader_mmsr/parent_ui/history.dart';
import 'package:reader_mmsr/parent_ui/pickLanguages.dart';
import '../utils/swipe_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'pickLanguages.dart';

//Page to show a list of children account under the main account

class ChildrenAccount extends StatefulWidget {
  List childData;
  @override
  ChildrenAccount({Key key, this.childData}) : super(key: key);
  _ChildrenAccount_State createState() => new _ChildrenAccount_State();
}

// ignore: camel_case_types
class _ChildrenAccount_State extends State<ChildrenAccount>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String url = 'http://10.0.2.2/mmsr/';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Manage Children Account',
              style: TextStyle(fontFamily: "WorkSansBold")),
          backgroundColor: Colors.lightBlue),
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
    return widget.childData.length ==
            0 //widget.childData is object of _ChildrenAccount_State
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/img/empty.png",
                  fit: BoxFit.cover,
                ),
                Text(
                  "Account list is empty!",
                  style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: widget.childData == null ? 0 : widget.childData.length,
            itemBuilder: (context, i) {
              return Container(
                padding: EdgeInsets.only(top: 3),
                child: Card(
                    elevation: 10,
                    //padding: EdgeInsets.only(top:5.0,left: 10,right:10),
                    child: OnSlide(
                      items: <ActionItems>[
                        new ActionItems(
                            icon: new IconButton(
                              icon: new Icon(FontAwesomeIcons.trash),
                              onPressed: () {},
                              color: Colors.white,
                            ),
                            onPress: () {
                              deleteChild(i);
                            },
                            backgroudColor: Colors.red),
                      ],
                      child: ListTile(
                        leading: widget.childData[i].children_gender == 'M'
                            ? Icon(FontAwesomeIcons.male)
                            : Icon(FontAwesomeIcons.female),
                        title: Text(
                          widget.childData[i].children_name,
                          style: TextStyle(fontFamily: "WorkSansSemiBold"),
                        ),
                        trailing: PopupMenuButton<int>(
                          onSelected: (value) {
                            choiceAction(value, i);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text(
                                "Set Language",
                                style: TextStyle(fontFamily: 'WorkSansBold'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text(
                                "History",
                                style: TextStyle(fontFamily: 'WorkSansBold'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: GestureDetector(
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'WorkSansBold'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              );
            },
          );
  }

  void choiceAction(int choice, int i) async {
    //user selected actions, e.g. "Delete","Check History"
    String url = 'http://10.0.2.2/mmsr/';

    if (choice == 1) {
      bool connection = false;
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          connection = true;
        }
      } on SocketException catch (_) {
        connection = false;
      }
      if (connection == true) {
        //if internet is available
        final response = await http.post(
          url + "getLanguage.php",
        );
        var data = json.decode(response.body);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PickLanguageLoad(
                    languageList: data, id: widget.childData[i].children_id)));
        print('Set Language');
      } else if (connection == false) {
        showInSnackBar('No internet connection');
      }
    } else if (choice == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoadDate(childrenID: widget.childData[i].children_id)));
    } else if (choice == 3) {
      bool connection = false;
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          connection = true;
        }
      } on SocketException catch (_) {
        connection = false;
      }

      if (connection == true) {
        deleteChild(i);
      } else if (connection == false) {
        showInSnackBar('No internet connection');
      }
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

  void deleteChild(int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          actions: <Widget>[
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                FlatButton(
                    color: Colors.amber,
                    onPressed: () async {
                      setState(() {
                        //delete all child account data in local database
                        //no delete child account in server because the data in server can be used
                        var db = DBHelper();
                        db.deleteStats(widget.childData[i].children_id);
                        db.deleteChildren(widget.childData[i].children_id);
                        http.post(url + "deleteLanguagePreferred(Reader).php",
                            body: {
                              "children_id": widget.childData[i].children_id,
                            });
                        db.deleteLanguagePreferred(
                            widget.childData[i].children_id);
                        db.deleteAllBook(widget.childData[i].children_id);
                        db.deleteAllText(widget.childData[i].children_id);
                        db.deleteAllOngoing(widget.childData[i].children_id);
                        db.deleteStats(widget.childData[i].children_id);
                        //db.deleteAllImage(widget.childData[i].children_id);
                        widget.childData.removeAt(i);
                        
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          ],
        );
      },
    );
  }
}
