import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;

//Children reading history page

//Load all data from local database
class LoadDate extends StatefulWidget{
  String childrenID;
  @override
  LoadDate({Key key,this.childrenID}) : super(key:key);
  LoadDate_state createState() => new LoadDate_state();
}

class LoadDate_state extends State<LoadDate> with SingleTickerProviderStateMixin {
  List data,historyDate;

  var db = DBHelper();
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: new FutureBuilder<List>(
          future: db.getHistoryDistinct(widget.childrenID),//"db." is retrieve data from local database,"widget.childrenID" is object of LoadDate_state
          builder: (context, snapshot) {
            if(snapshot.hasData)
              {
                historyDate = snapshot.data;
                return new FutureBuilder<List>(
                  future: db.getHistory(widget.childrenID),
                  builder: (context, snapshot2) {

                    if(snapshot2.hasData)
                      {
                        data = snapshot2.data;
                        return new HistoryPage(
                            historyDate: historyDate,
                            childrenID:widget.childrenID,
                            data:data //pass data to next widget
                        );
                      }
                    return SpinKitThreeBounce(color: Colors.blue);
                  },
                );
              }
            return SpinKitThreeBounce(color: Colors.blue);
          },
        )

    );
  }

}

class HistoryPage extends StatefulWidget{
  List data,historyDate;
  String childrenID;
  @override
  HistoryPage({Key key,this.data,this.historyDate,this.childrenID}) : super(key:key);
  HistoryPage_state createState() => new HistoryPage_state();
}

class HistoryPage_state extends State<HistoryPage> with SingleTickerProviderStateMixin {

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
    return Scaffold(
      appBar: new AppBar(title: new Text('Reading History',
        style: TextStyle(
        color: Colors.white,
    ),), backgroundColor: Colors.lightBlue,
      ),
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

            child: _buildHistory(context),
          ),
        ),
      ),
    );

  }
  Widget _buildHistory(BuildContext context) //Using Nested listview in this page
  {
    return widget.historyDate.isEmpty ?Center(
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center ,
        children: <Widget>[
          Image.asset("assets/img/error.png",fit: BoxFit.cover,),
          Text(
            "No Reading History!",
            style: TextStyle(fontFamily: "WorkSansBold",fontSize: 20),
          ),
        ],
      ),)
    :ListView.builder(
        shrinkWrap: true,

        itemCount: widget.historyDate.isEmpty?0:widget.historyDate.length,
        itemBuilder: (context,i)
        {
          List historyList = [];
          for(int j = 0;j<widget.data.length;j++)
            {
              if(widget.historyDate[i].read_date == widget.data[j].read_date)
                {
                  historyList.add(widget.data[j]);
                }
            }
          return Container(
            padding: EdgeInsets.only(top:5),
            margin: EdgeInsets.all(5),
            child: Card(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20,bottom: 5,top: 5),
                    alignment: Alignment.topLeft,
                    child: Text("Date: ${widget.historyDate[i].read_date}",style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'WorkSansBold',
                    ),),
                  ),
                Row(
                  children: <Widget>[
                   Container(
                      width: MediaQuery.of(context).size.width*3/4,
                     padding: EdgeInsets.only(top: 5,left: 25),
                     alignment: Alignment.topLeft,
                     child: Text("Story Name",style: TextStyle(
                       fontSize: 15,
                       fontFamily: 'WorkSansBold',
                     ),),
                   ),
                   Container(
                       padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.topRight,
                      child: Text( "Duration",style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'WorkSansBold',
                    ),),
                ),
              ],
            ),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: historyList.length,
                        itemBuilder: (context, k)
                        {
                          return
                              Container(
                                margin: EdgeInsets.only(top:3,bottom: 3),
                                color:Colors.blueGrey.withOpacity(0.2),

                                child: Row(
                                  children: <Widget>[
                                    Wrap(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width*3/4,
                                          padding: EdgeInsets.only(top: 5,left:20,right: 5),
                                          alignment: Alignment.topLeft,
                                          child:
                                          Text( "${historyList[k].story_title}",style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'WorkSansMedium',
                                          ),),
                                        ),
                                        Container(

                                          padding: EdgeInsets.only(top: 5),
                                          alignment: Alignment.topRight,
                                          child: Text( "${historyList[k].duration} mins",style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'WorkSansMedium',
                                          ),),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              );
                        }
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  }
