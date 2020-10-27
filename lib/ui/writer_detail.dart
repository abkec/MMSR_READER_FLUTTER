import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/Model/PageImageModel.dart';
import 'package:reader_mmsr/Model/PageTextModel.dart';
import 'package:reader_mmsr/utils/transparent_image.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'book_list.dart';

//Load all neccessary data from local database and server database.
class WriterDetails extends StatefulWidget {
  List writer, languageData, review;
  String childrenID;
  Children childData;
  int index;
  String contributorID;
  WriterDetails({
    Key key,
    this.writer,
    this.languageData,
    this.review,
    this.childData,
    this.childrenID,
    this.contributorID,
    this.index,
  }) : super(key: key);
  @override
  _WriterDetailState createState() => new _WriterDetailState();
}

class _WriterDetailState extends State<WriterDetails> {
  var db = DBHelper();
  String url = 'http://10.0.2.2/mmsr/';
  void initState() {
    getStories();
    super.initState();
  }

  Future<List> getStories() async //retrieve all review data from server
  {
    final response = await http.post(
      url + "getWriterStories(Reader).php",
      body: {"ContributorID": widget.contributorID},
    );
    var story = json.decode(response.body);
    return story;
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
        future:
            getStories(), //widget.childrenID. Means using object of _LoadDetailState. The data are passed by previous pages.
        builder: (context, snapshot) {
          // if (snapshot.hasError) print(snapshot.error);
          if (snapshot.hasData) {
            return new FutureBuilder<List>(
                //if equal to true then continue retrieve other data
                future: db.getStats(widget.childrenID),
                builder: (context, snapshot2) {
                  if (snapshot2.hasData) {
                    return new FutureBuilder<List>(
                        //if equal to true then continue retrieve other data
                        future: getFollowing(),
                        builder: (context, snapshot3) {
                          if (snapshot3.hasData) {
                            return new DetailWriter(
                              stats: snapshot2.data,
                              bookData: snapshot.data,
                              childData: widget.childData,
                              languageData: widget.languageData,
                              review: widget.review,
                              childrenID: widget.childrenID,
                              index: widget.index,
                              writer: widget.writer,
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

class DetailWriter extends StatefulWidget {
  List bookData, following, writer, languageData, review, stats;
  String childrenID;
  Children childData;
  int index;
  String contributorID;
  DetailWriter({
    Key key,
    this.stats,
    this.bookData,
    this.childData,
    this.languageData,
    this.review,
    this.following,
    this.childrenID,
    this.index,
    this.writer,
    this.contributorID,
  }) : super(key: key);
  @override
  _DetailWriterState createState() => new _DetailWriterState();
}

class _DetailWriterState extends State<DetailWriter> {
  String url = 'http://10.0.2.2/mmsr/';
  bool exist = false, follow = false;

  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    //app bar
    print(widget.index);
    setState(() {
      if (widget.following.length > 0) follow = true;
    });

    final appBar = AppBar(
      elevation: .5,
      title: Text(widget.writer[widget.index]['Name']),
      actions: <Widget>[],
    );

    ///detail of book image and it's pages
    // Uint8List bytes =
    //     base64Decode(widget.bookData[widget.index]['storybookCover']);

    final top = Container(
      height: 150,
      width: 150,
      child: Stack(alignment: Alignment.center, children: <Widget>[
        Container(
          height: 120,
          width: 120,
          child: Image.asset("assets/img/fox.png", fit: BoxFit.cover),
        ),

        // Image.memory(
        //   bytes,
        //   fit: BoxFit.cover,
        // ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            shadowColor: Colors.blue.shade200,
            elevation: 5.0,
            child: Tooltip(
              message: follow == true ? "Unfollowed" : "Follow",
              child: IconButton(
                icon:
                    follow == true ? Icon(Icons.done) : Icon(Icons.person_add),
                onPressed: () async {
                  follow == true ? unfollowWriter() : followWriter();
                },
              ),
            ),
          ),
        ),
      ]),
    );

    final bot = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              widget.bookData.length.toString(),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Text(
              'Story\nPublished',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'SourceSansLight'),
              textAlign: TextAlign.center,
            )
          ],
        ),
        SizedBox(
          width: 25,
        ),
        Column(
          children: <Widget>[
            Text(
              widget.writer[widget.index]['followers'].toString(),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Text(
              'Followers\n ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'SourceSansLight'),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ],
    );

    final topContent = Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          top,
          SizedBox(
            height: 10,
          ),
          bot,
        ],
      ),
    );

    final _buildCollection = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Color(0xFFF1F1F1),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.bookData.length,
                    itemBuilder: (context, i) {
                      String language;
                      //To check what is the language of the story.
                      for (int j = 0; j < widget.languageData.length; j++) {
                        if (widget.bookData[i]['languageCode'] ==
                            widget.languageData[j]['languageCode']) {
                          language = widget.languageData[j]['languageDesc'];
                        }
                      }

                      bool rating = false;
                      for (int j = 0; j < widget.review.length; j++) {
                        if (widget.review[j]['storybookID'] ==
                                widget.bookData[i]['storybookID'] &&
                            widget.review[j]['languageCode'] ==
                                widget.bookData[i]['languageCode']) {
                          rating = true;
                          break;
                        }
                      }

                      Uint8List bytes =
                          base64Decode(widget.bookData[i]['storybookCover']);
                      return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                        child: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                child: Card(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                          color: Colors.grey,
                                        )),
                                        alignment: Alignment.center,
                                        child: Container(
                                          child: FadeInImage(
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                            image: MemoryImage(bytes),
                                            placeholder:
                                                MemoryImage(kTransparentImage),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  widget.bookData[i]
                                                      ['storybookTitle'],
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'SourceSansBold',
                                                      fontSize: 20),
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: rating == true
                                                  ? Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child:
                                                          FlutterRatingBarIndicator(
                                                        itemPadding:
                                                            EdgeInsets.only(
                                                                right: 1),
                                                        rating: double.parse(widget
                                                                        .bookData[i]
                                                                    [
                                                                    'rating']) ==
                                                                null
                                                            ? 0
                                                            : double.parse(widget
                                                                    .bookData[i]
                                                                ['rating']),
                                                        itemCount: 5,
                                                        itemSize: 15.0,
                                                        emptyColor:
                                                            Color(0xFF000000),
                                                      ),
                                                    )
                                                  : Text(
                                                      "(No rating yet)",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'SourceSansRegular'),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      softWrap: false,
                                                    ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: Text(
                                                  language,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'SourceSansLight'),
                                                  overflow: TextOverflow.clip,
                                                  softWrap: false,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => LoadContent(
                                //               storyID: storycollection[i]
                                //                   .story_id,
                                //               childrenID: widget.childrenID,
                                //               storyTitle: storycollection[i]
                                //                   .story_title,
                                //               storyLanguage:
                                //                   storycollection[i]
                                //                       .languageCode,
                                //             )),
                                //   );
                                // },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
              Text('Published Storybooks',
                  style: TextStyle(
                    fontSize: 25.0,
                    height: 1.5,
                    letterSpacing: -1.0,
                    fontFamily: 'SourceSansBold',
                  )),
              SizedBox(height: 5),
              _buildCollection,
              SizedBox(height: 20),
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

    http.post(url + "followWriter.php", body: {
      'children_id': widget.childrenID,
      'ContributorID': widget.contributorID,
      'download_date': dateFormat.format(DateTime.now()),
    });

    Future.delayed(new Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoadBook(
                  childData: widget.childData, childrenID: widget.childrenID)),
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
              builder: (context) => LoadBook(
                  childData: widget.childData, childrenID: widget.childrenID)),
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
