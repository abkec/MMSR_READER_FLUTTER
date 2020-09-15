import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

//Story details Page
//Download function available
//This page of code will be messy due to referencing from online resources

//Load all neccessary data from local database and server database.
class LoadDetail extends StatefulWidget {
  List bookData, reviewAll, languageData, contributorList;
  String childrenID, language;
  int index;
  String contributor, contributorID;
  LoadDetail(
      {Key key,
      this.bookData,
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
  String url = 'http://10.0.2.2/mmsr/';
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
                        future: getReview(),
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData) {
                            return new Detail(
                              localData: snapshot.data,
                              bookData: widget.bookData,
                              childrenID: widget.childrenID,
                              index: widget.index,
                              contributor: widget.contributor,
                              contributorList: widget.contributorList,
                              reviewAll: widget.reviewAll,
                              languageData: widget.languageData,
                              language: widget.language,
                              review: snapshot2.data,
                              contributorID: widget.contributorID,
                              following: snapshot3.data,
                              //Passing data into next widget.
                            );
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
      localData,
      review,
      following,
      reviewAll,
      contributorList,
      languageData;
  String childrenID, language;
  int index;
  String contributor, contributorID;
  Detail(
      {Key key,
      this.bookData,
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
  String url = 'http://10.0.2.2/mmsr/';
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

    setState(() {
      if (widget.following.length > 0) follow = true;
    });

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
            size: 25, isBold: true, padding: EdgeInsets.only(top: 16.0)),
        Padding(
          padding: EdgeInsets.only(left: 8, top: 0, bottom: 0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: 'by ${widget.contributor}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WriterDetails(
                                    writer: widget.contributorList,
                                    languageData: widget.languageData,
                                    review: widget.reviewAll,
                                    childrenID: widget.childrenID,
                                    index: conIndex,
                                    contributorID: widget.contributorID,
                                  )),
                        );
                      }),
              ],
            ),
          ),
        ),
        text(
          'Genre: ${widget.bookData[widget.index]['storybookGenre']}',
          isBold: true,
          padding: EdgeInsets.only(right: 8.0, top: 10),
        ),
        text(
          'Created: ${widget.bookData[widget.index]['dateOfCreation']}',
          isBold: true,
          padding: EdgeInsets.only(top: 5, right: 8.0),
        ),
        Container(height: 5),
        Row(
          children: <Widget>[
            text(
              'Rating: ',
              isBold: true,
              padding: EdgeInsets.only(right: 8.0),
            ),
            rating == true
                ? FlutterRatingBarIndicator(
                    rating:
                        double.parse(widget.bookData[widget.index]['rating']),
                    itemCount: 5,
                    itemSize: 20.0,
                    emptyColor: Colors.amber.withAlpha(50),
                  )
                : text(
                    "(No rating yet)",
                    isBold: true,
                    padding: EdgeInsets.only(right: 8.0),
                  ),
          ],
        ),
        SizedBox(height: 32.0),
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
                    follow == true ? unfollowWriter() : followWriter();
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
              SizedBox(height: 20),
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
                              Text(widget.review[i]['children_name'],
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      height: 1.5,
                                      fontFamily: 'WorkSansLight')),
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
                              SizedBox(height: 20),
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

    http.post(url + "download_record.php", body: {
      'storybookID': widget.bookData[widget.index]['storybookID'],
      'children_id': widget.childrenID,
      'languageCode': widget.bookData[widget.index]['languageCode'],
      'download_date': dateFormat.format(DateTime.now()),
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

    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoadBook(childrenID: widget.childrenID)),
          (Route<dynamic> route) => false);
    });
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

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    print(dateFormat.format(DateTime.now()));
    http.post(url + "followWriter.php", body: {
      'children_id': widget.childrenID,
      'ContributorID': widget.contributorID,
      'download_date': dateFormat.format(DateTime.now()),
    });

    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoadBook(childrenID: widget.childrenID)),
          (Route<dynamic> route) => false);
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

    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoadBook(childrenID: widget.childrenID)),
          (Route<dynamic> route) => false);
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
