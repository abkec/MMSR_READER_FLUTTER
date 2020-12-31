import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/Model/PageImageModel.dart';
import 'package:reader_mmsr/Model/PageTextModel.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reader_mmsr/Model/StoryModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:reader_mmsr/ui/writer_detail.dart';
import 'book_list.dart';
import 'page_content.dart';
import 'dart:io';

//Story details Page
//Download function available
//This page of code will be messy due to referencing from online resources

//Load all neccessary data from local database and server database.
class LoadDetail extends StatefulWidget {
  List bookData, reviewAll, languageData, contributorList;
  Children childData;
  String childrenID, language;
  int index;
  String contributor, contributorID;
  LoadDetail(
      {Key key,
      this.bookData,
      this.childData,
      this.contributorList,
      this.reviewAll,
      this.languageData,
      this.childrenID,
      this.contributorID,
      this.language,
      this.index,
      this.contributor})
      : super(key: key);
  @override
  _LoadDetailState createState() => new _LoadDetailState();
}

class _LoadDetailState extends State<LoadDetail> {
  var db = DBHelper();
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';
  void initState() {
    getReview();
    super.initState();
  }

  Future<List> getReview() async //retrieve all review data from server
  {
    final response = await http.post(
      url + "getRating.php",
      body: {
        "storybookID": widget.bookData[widget.index]['storybookID'],
        "language": widget.bookData[widget.index]['languageCode']
      },
    );
    var reviewData = json.decode(response.body);
    return reviewData;
  }

  Future<List> getLowHighRating() async //retrieve all writer data from server
  {
    final response = await http.post(
      url + "getLowHighRating2.php",
      body: {"storyID": widget.bookData[widget.index]['storybookID']},
    );
    var lowHighRating = json.decode(response.body);
    return lowHighRating;
  }

  Future<List> getFollowing() async //retrieve all following from server
  {
    final response = await http.post(
      url + "getFollowing2.php",
      body: {
        "childrenID": widget.childrenID,
        "ContributorID": widget.contributorID
      },
    );
    var datauser = json.decode(response.body);
    return datauser;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new FutureBuilder<List>(
        future: db.getStories(widget
            .childrenID), //widget.childrenID. Means using object of _LoadDetailState. The data are passed by previous pages.
        builder: (context, snapshot) {
          // if (snapshot.hasError) print(snapshot.error);
          if (snapshot.hasData) {
            return new FutureBuilder<List>(
                //if equal to true then continue retrieve other data
                future: getFollowing(),
                builder: (context, snapshot3) {
                  if (snapshot3.hasData) {
                    return new FutureBuilder<List>(
                        //if equal to true then continue retrieve other data
                        future: getLowHighRating(),
                        builder: (context, lowHigh) {
                          if (lowHigh.hasData) {
                            return new FutureBuilder<List>(
                                //if equal to true then continue retrieve other data
                                future: db.getStats(widget.childrenID),
                                builder: (context, snapshot4) {
                                  if (snapshot4.hasData) {
                                    return new FutureBuilder<List>(
                                        //if equal to true then continue retrieve other data
                                        future: getReview(),
                                        builder: (context, snapshot2) {
                                          if (snapshot2.hasData) {
                                            return new Detail(
                                              lowHigh: lowHigh.data,
                                              stats: snapshot4.data,
                                              localData: snapshot.data,
                                              bookData: widget.bookData,
                                              childrenID: widget.childrenID,
                                              index: widget.index,
                                              childData: widget.childData,
                                              contributor: widget.contributor,
                                              contributorList:
                                                  widget.contributorList,
                                              reviewAll: widget.reviewAll,
                                              languageData: widget.languageData,
                                              language: widget.language,
                                              review: snapshot2.data,
                                              contributorID:
                                                  widget.contributorID,
                                              following: snapshot3.data.length > 0 ? true : false,
                                              //Passing data into next widget.
                                            );
                                          } else {
                                            return new Center(
                                              child:
                                                  new CircularProgressIndicator(),
                                            );
                                          }
                                        });
                                  } else {
                                    return new Center(
                                      child: new CircularProgressIndicator(),
                                    );
                                  }
                                });
                          } else {
                            return new Center(
                              child: new CircularProgressIndicator(),
                            );
                          }
                        });
                  } else {
                    return new Center(
                      child: new CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Detail extends StatefulWidget {
  List bookData,
      lowHigh,
      stats,
      localData,
      review,
      reviewAll,
      contributorList,
      languageData;
  bool following;
  String childrenID, language;
  Children childData;
  int index;
  String contributor, contributorID;
  Detail(
      {Key key,
      this.lowHigh,
      this.stats,
      this.bookData,
      this.childData,
      this.following,
      this.childrenID,
      this.language,
      this.index,
      this.contributor,
      this.contributorList,
      this.reviewAll,
      this.languageData,
      this.contributorID,
      this.localData,
      this.review})
      : super(key: key);
  @override
  _DetailState createState() => new _DetailState();
}

class _DetailState extends State<Detail> {
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';
  bool exist = false, follow = false;
  String storyLanguage = '', storyID = '', storyTitle = '';
  int conIndex;

  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    for (int i = 0; i < widget.contributorList.length; i++) {
      if (widget.contributorList[i]['ContributorID'] == widget.contributorID) {
        conIndex = widget.contributorList.indexOf(widget.contributorList[i]);
        break;
      }
    }

    print(widget.stats);

    //app bar
    for (int i = 0; i < widget.localData.length; i++) {
      setState(() {
        //if the local database has the same story and same language of the story retrieve from server
        //data of widget.bookData is story details retrieve from server
        if (widget.localData[i].story_id ==
                widget.bookData[widget.index]['storybookID'] &&
            widget.localData[i].languageCode ==
                widget.bookData[widget.index]['languageCode']) {
          exist = true;
          storyLanguage = widget.localData[i].languageCode;
          storyTitle = widget.localData[i].story_title;
          storyID = widget.localData[i].story_id;
        }
      });
    }

    follow = widget.following;

    final appBar = AppBar(
      elevation: .5,
      title: Text('Books Details'),
      actions: <Widget>[],
    );

    ///detail of book image and it's pages
    Uint8List bytes =
        base64Decode(widget.bookData[widget.index]['storybookCover']);

    bool rating = false;
    for (int j = 0; j < widget.review.length; j++) {
      if (widget.review[j]['storybookID'] ==
              widget.bookData[widget.index]['storybookID'] &&
          widget.review[j]['languageCode'] ==
              widget.bookData[widget.index]['languageCode']) {
        rating = true;
        break;
      }
    }

    final topLeft = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Hero(
            tag: widget.bookData[widget.index]['storybookID'],
            child: Container(
              height: 200,
              child: Card(
                child: Image.memory(
                  bytes,
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        //text('${book.pages} pages', color: Colors.black38, size: 12)
      ],
    );

    ///detail top right
    final topRight = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text(widget.bookData[widget.index]['storybookTitle'],
            size: 22,
            isBold: true,
            color: Colors.white,
            padding: EdgeInsets.only(top: 16.0)),
        SizedBox(height: 10),
        Material(
          borderRadius: BorderRadius.circular(20.0),
          shadowColor: Colors.blue.shade200,
          elevation: 5.0,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'by ${widget.contributor}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WriterDetails(
                                        childData: widget.childData,
                                        writer: widget.contributorList,
                                        languageData: widget.languageData,
                                        review: widget.reviewAll,
                                        childrenID: widget.childrenID,
                                        index: conIndex,
                                        contributorID: widget.contributorID,
                                      )),
                            );
                          } else if (connection == false) {
                            showInSnackBar('No internet connection');
                          }
                        }),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Table(
          //Column width is adjusted automatically based on text lengths
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: [
            TableRow(
              children: [
                text(
                  'Genre',
                  color: Colors.white,
                  isBold: true,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
                text(
                  '${widget.bookData[widget.index]['storybookGenre']}',
                  color: Colors.white70,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
              ],
            ),
            TableRow(
              children: [
                text(
                  'Level',
                  color: Colors.white,
                  isBold: true,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
                text(
                  '${widget.bookData[widget.index]['ReadabilityLevel']}',
                  color: Colors.white70,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
              ],
            ),
            TableRow(
              children: [
                text(
                  'Created',
                  color: Colors.white,
                  isBold: true,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
                text(
                  '${widget.bookData[widget.index]['PublishedDate']}',
                  color: Colors.white70,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
              ],
            ),
            TableRow(
              children: [
                text(
                  'Rating',
                  color: Colors.white,
                  isBold: true,
                  padding: EdgeInsets.only(right: 8.0, top: 10),
                ),
                rating == true
                    ? Container(
                        padding: EdgeInsets.only(top: 6),
                        child: FlutterRatingBarIndicator(
                          rating: double.parse(
                              widget.bookData[widget.index]['rating']),
                          itemCount: 5,
                          itemSize: 16.0,
                          emptyColor: Colors.amber.withAlpha(100),
                        ),
                      )
                    : text(
                        "(No rating yet)",
                        color: Colors.white70,
                        padding: EdgeInsets.only(right: 8.0, top: 10),
                      ),
              ],
            ),
          ],
        ),
        SizedBox(height: 25.0),
        Row(
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.circular(20.0),
              shadowColor: Colors.blue.shade200,
              elevation: 5.0,
              child: Tooltip(
                message: exist == true ? "Read" : "Download",
                child: IconButton(
                  icon: exist == true
                      ? Icon(Icons.import_contacts)
                      : Icon(Icons.file_download),
                  onPressed: () async {
                    exist == true
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoadContent(
                                    storyID: storyID,
                                    childrenID: widget.childrenID,
                                    storyTitle: storyTitle,
                                    storyLanguage: storyLanguage)),
                          )
                        : download();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Material(
              borderRadius: BorderRadius.circular(20.0),
              shadowColor: Colors.blue.shade200,
              elevation: 5.0,
              child: Tooltip(
                message: follow == true ? "Unfollowed" : "Follow",
                child: IconButton(
                  icon: follow == true
                      ? Icon(Icons.done)
                      : Icon(Icons.person_add),
                  onPressed: () async {
                    bool connection = false;
                    try {
                      final result = await InternetAddress.lookup('google.com');
                      if (result.isNotEmpty &&
                          result[0].rawAddress.isNotEmpty) {
                        connection = true;
                      }
                    } on SocketException catch (_) {
                      connection = false;
                    }
                    print(connection);
                    if (connection == true) {
                      follow == true ? unfollowWriter() : followWriter();
                    } else if (connection == false) {
                      showInSnackBar('No internet connection');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final topContent = Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(flex: 2, child: topLeft),
          Flexible(flex: 3, child: topRight),
        ],
      ),
    );

    ///scrolling text description
    final bottomContent = Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Description',
                  style: TextStyle(
                      fontSize: 25.0,
                      height: 1.5,
                      fontFamily: 'WorkSansSemiBold')),
              SizedBox(height: 5),
              Text(
                widget.bookData[widget.index]['storybookDesc'],
                style: TextStyle(
                    fontSize: 15.0, height: 1.5, fontFamily: 'WorkSansLight'),
              ),
              SizedBox(height: 30),
              widget.lowHigh.length != 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 27,
                              child: Image.asset("assets/img/recommend.png"),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Highly recommended',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  height: 1.5,
                                  fontFamily: 'WorkSansSemiBold'),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.lowHigh[0]['comment'],
                            style: TextStyle(
                                fontSize: 15.0,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'WorkSansLight'),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 30),
              rating == true
                  ? Text('Review',
                      style: TextStyle(
                          fontSize: 25.0,
                          height: 1.5,
                          fontFamily: 'WorkSansSemiBold'))
                  : Container(),
              rating == true ? SizedBox(height: 5) : Container(),
              rating == true
                  ? Container(
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount:
                            widget.review == null ? 0 : widget.review.length,
                        itemBuilder: (context, i) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(widget.review[i]['children_name'],
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          height: 1.5,
                                          fontFamily: 'WorkSansMedium')),
                                  Text(widget.review[i]['rating_date'],
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          height: 1.5,
                                          fontFamily: 'WorkSansLight')),
                                ],
                              ),
                              SizedBox(height: 5),
                              Container(
                                child: FlutterRatingBarIndicator(
                                  itemPadding: EdgeInsets.only(right: 1),
                                  rating: double.parse(
                                              widget.review[i]['value']) ==
                                          null
                                      ? 0
                                      : double.parse(widget.review[i]['value']),
                                  itemCount: 5,
                                  itemSize: 15.0,
                                  emptyColor: Color(0xFF525252),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                  widget.review[i]['comments'].isEmpty
                                      ? "(No comments)"
                                      : widget.review[i]['comments'],
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      height: 1.5,
                                      fontFamily: 'WorkSansLight')),
                              SizedBox(
                                height: 10,
                              ),
                              i < widget.review.length - 1
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0.6),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );

    //Main Scaffold Here
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: Column(
        children: <Widget>[
          topContent,
          bottomContent,
        ],
      ),
    );
  }

  ///create text widget
  text(String data,
          {Color color = Colors.black87,
          num size = 14,
          EdgeInsetsGeometry padding = EdgeInsets.zero,
          bool isBold = false}) =>
      Padding(
        padding: padding,
        child: Text(
          data,
          style: TextStyle(
              color: color,
              fontSize: size.toDouble(),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      );

  void download() async //download all details and pages of the story
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          height: 200,
          width: 50,
          child: Center(
            child: SpinKitThreeBounce(color: Colors.blue),
          ),
        ));
      },
    );
    String speech_id = '';
    final r = await http.post(url + "getSpeech.php");
    var speechData = json.decode(r.body);
    for (int i = 0; i < speechData.length; i++) {
      if (speechData[i]['languageCode'] ==
          widget.bookData[widget.index]['languageCode']) {
        speech_id = speechData[i]['speech_id'];
      }
    }

    final response = await http.post(url + "getPageText(Reader).php", body: {
      'storybookID': widget.bookData[widget.index]['storybookID'],
      'languageCode': widget.bookData[widget.index]['languageCode']
    });
    var pageData = json.decode(response.body);

    final r2 = await http.post(url + "getImage.php", body: {
      'storybookID': widget.bookData[widget.index]['storybookID'],
    });
    // var pageImage = json.decode(r2.body);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    var db = DBHelper();
    var story = StoryCollection(
        widget.bookData[widget.index]['storybookID'],
        widget.childrenID,
        widget.bookData[widget.index]['storybookCover'],
        widget.bookData[widget.index]['storybookTitle'],
        dateFormat.format(DateTime.now()),
        widget.contributor,
        widget.bookData[widget.index]['languageCode'],
        widget.language);
    db.downloadBook(story);

    widget.stats[0].num_download += 1;
    db.updateStats(widget.stats[0]);

    http.post(url + "download_record.php", body: {
      'storybookID': widget.bookData[widget.index]['storybookID'],
      'children_id': widget.childrenID,
      'languageCode': widget.bookData[widget.index]['languageCode'],
      'download_date': dateFormat.format(DateTime.now()),
    });

    http.post(url + "addLogChildren(Reader).php", body: {
      'children_id': widget.childrenID,
      'title': 'Download Storybook',
      'description': widget.childrenID +
          ' has downloaded a storybook: ' +
          widget.bookData[widget.index]['storybookID'],
    });

//    if(pageImage.length>0)
//    {
//      print(pageImage.length);
//      for(int i = 0;i<pageData.length;i++)
//      {
//        var pageImagedata = PageImageModel(widget.childrenID,pageImage[i]['storybookID'],pageImage[i]['pagePhoto']
//            ,int.parse(pageImage[i]['pageNo']));
//        db.downloadImage(pageImagedata);
//      }
//    }
    if (pageData.length > 0) {
      print(widget.language);
      for (int i = 0; i < pageData.length; i++) {
        var pageText = PageTextModel(
            widget.childrenID,
            pageData[i]['storybookID'],
            pageData[i]['pageContent'],
            pageData[i]['languageCode'],
            widget.language,
            int.parse(
              pageData[i]['pageNo'],
            ),
            speech_id,
            pageData[i]['pagePhoto']);
        db.downloadText(pageText);
      }
    }

    // setState(() {
    //   exist = true;
    //   storyLanguage = widget.bookData[widget.index]['languageCode'];
    //   storyTitle = widget.bookData[widget.index]['storybookTitle'];
    //   storyID = widget.bookData[widget.index]['storybookID'];
    //   widget.
    // });

    // Navigator.of(context, rootNavigator: true).pop();
    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoadBook(
                  childData: widget.childData, childrenID: widget.childrenID)),
          (Route<dynamic> route) => false);
    });
  }

  Future<List> getFollowing() async //retrieve all following from server
  {
    final response = await http.post(
      url + "getFollowing.php",
      body: {
        "childrenID": widget.childrenID,
      },
    );
    var datauser = json.decode(response.body);
    return datauser;
  }

  void followWriter() async //follow writer
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          height: 200,
          width: 50,
          child: Center(
            child: SpinKitThreeBounce(color: Colors.blue),
          ),
        ));
      },
    );

    var db = DBHelper();
    widget.stats[0].num_follow += 1;
    db.updateStats(widget.stats[0]);

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    print(dateFormat.format(DateTime.now()));
    http.post(url + "followWriter.php", body: {
      'children_id': widget.childrenID,
      'ContributorID': widget.contributorID,
      'follow_date': dateFormat.format(DateTime.now()),
    });

    http.post(url + "addLogChildren(Reader).php", body: {
      'children_id': widget.childrenID,
      'title': 'Follow Contributor',
      'description': widget.childrenID +
          ' has followed a contributor: ' +
          widget.contributorID,
    });

    Future.delayed(new Duration(seconds: 1), () {
      //   Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(
      //           builder: (context) => LoadBook(
      //               childData: widget.childData, childrenID: widget.childrenID)),
      //       (Route<dynamic> route) => false);
      setState(() {
        follow = true;
        widget.following = true;
        int flw = int.parse(widget.contributorList[conIndex]['followers']) + 1;
        widget.contributorList[conIndex]['followers'] = flw.toString();
      });

      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void unfollowWriter() async //unfollow writer
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          height: 200,
          width: 50,
          child: Center(
            child: SpinKitThreeBounce(color: Colors.blue),
          ),
        ));
      },
    );

    http.post(url + "unfollowWriter.php", body: {
      'children_id': widget.childrenID,
      'ContributorID': widget.contributorID,
    });

    http.post(url + "addLogChildren(Reader).php", body: {
      'children_id': widget.childrenID,
      'title': 'Unfollow Contributor',
      'description': widget.childrenID +
          ' has unfollowed a contributor: ' +
          widget.contributorID,
    });

    Future.delayed(new Duration(seconds: 1), () {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //         builder: (context) => LoadBook(
      //             childData: widget.childData, childrenID: widget.childrenID)),
      //     (Route<dynamic> route) => false);

      setState(() {
        follow = false;
        widget.following = false;
        int flw = int.parse(widget.contributorList[conIndex]['followers']) - 1;
        widget.contributorList[conIndex]['followers'] = flw.toString();
        
      });

      Navigator.of(context, rootNavigator: true).pop();
    });
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
