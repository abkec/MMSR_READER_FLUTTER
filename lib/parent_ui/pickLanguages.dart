import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_mmsr/Model/LanguagePreferredModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:http/http.dart' as http;

class PickLanguageLoad extends StatefulWidget{
  String id;
  List languageList;
  @override
  PickLanguageLoad({Key key,this.id,this.languageList}) : super(key: key);
  _PickLanguageLoad createState() => new _PickLanguageLoad();
}

class _PickLanguageLoad extends State<PickLanguageLoad> {

  var db = DBHelper();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: new FutureBuilder<List>(
        future: db.getLanguage(widget.id),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? new PickLanguage(
              languagesList: widget.languageList,
              preferred:snapshot.data,
              id:widget.id
          )
              : new Center(
                child: new CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class PickLanguage extends StatefulWidget{

  List languagesList,preferred;
  String id;
  @override
  PickLanguage({Key key,this.languagesList,this.preferred,this.id}) : super(key:key);
  PickLanguage_State createState() => new PickLanguage_State();
}
// ignore: camel_case_types
class PickLanguage_State extends State<PickLanguage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String url = 'http://10.0.2.2/mmsr/';

  var checkBox =[];
  void createValue()
  {
    for(int i=0;i< widget.languagesList.length;i++)
    {
      if(widget.preferred!=null)
        {
          for(int j = 0; j<widget.preferred.length;j++)
          {
            if(widget.languagesList[i]['languageCode']==widget.preferred[j].languageCode)
            {
              checkBox.add(true);
              i++;
            }
          }
        }

      checkBox.add(false);
    }
  }

  Future deleteData() async{
    http.post(url+"deleteLanguagePreferred(Reader).php",
        body: {
          "children_id": widget.id,
        });
    var db = DBHelper();
    db.deleteLanguagePreferred(widget.id);
  }
  Future insertData() async{
    for(int i = 0;i<widget.languagesList.length;i++)
    {
      if(checkBox[i]==true)
      {
        http.post(url+"addLanguagePreferred(Reader).php",
            body: {
              "children_id": widget.id,
              "languageCode": widget.languagesList[i]['languageCode'],
            });
        var db = DBHelper();
        var language = new LanguagePreferred(widget.id,widget.languagesList[i]['languageCode']);
        db.saveLanguagePreferred(language);
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    deleteData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Children Profile',style:TextStyle(fontFamily: "WorkSansBold")),backgroundColor: Colors.lightBlue,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        FlatButton(
          onPressed: ()
          {
            insertData();
            Navigator.of(context).pop();
          },
          child: Text('Done',style: TextStyle(fontFamily: "WorkSansMedium",fontSize: 18,color: Colors.lightGreenAccent)),
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
            height: MediaQuery.of(context).size.height,
            child: _buildLanguage(context),
          ),
        ),
      ),
    );
  }
  Widget _buildLanguage(BuildContext context)
  {
    createValue();
    return Container(
      child: ListView.builder(
          itemCount: widget.languagesList == null ? 0 :  widget.languagesList.length,
          itemBuilder: (context, i)
          {
            return Container(
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      title: Text( widget.languagesList[i]['languageDesc']),
                      value: checkBox[i],
                      onChanged: (bool value)
                      {
                        setState(() {
                          checkBox[i]=value;
                        });
                      },
                    ),

                    Container(
                      width: 500.0,
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ],
                )
            ) ;
          }
      ),
    );
  }
}