import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/Model/StoryModel.dart';
import 'package:reader_mmsr/Model/Storybook.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:reader_mmsr/parent_ui/parental_gate.dart';
import 'package:reader_mmsr/ui/writer_detail.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/utils/transparent_image.dart';
import 'package:reader_mmsr/utils/bubble_indication_painter.dart';
import 'detail.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'page_content.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../iconic_icons.dart';
import 'package:intl/intl.dart';

//LoadBook Widget to load all necessary data from local database and server database
class LoadBook extends StatefulWidget {
  Children childData;
  String childrenID;
  
  LoadBook({Key key, this.childrenID, this.childData})
      : super(key: key);
  @override
  _LoadBookState createState() => new _LoadBookState();
}

class _LoadBookState extends State<LoadBook> {
  List bookData,
      bookDataR,
      bookDataL,
      contributor,
      collection,
      languageData,
      review,
      following;
  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  var db = DBHelper();
  List bookList = [], bookList2 = [], bookList3 = [];
  var languageList, stats;

  Future<List> getFollowing() async //retrieve all following from server
  {
    final response = await http.post(
      url + "getFollowing.php",
      body: {"childrenID": widget.childrenID},
    );
    var datauser = json.decode(response.body);
    return datauser;
  }

  //all functions retrieve data from server database
  Future<List> getStories() async //retrieve all stories from server
  {
    final response = await http.post(url + "getStories(Reader).php");
    var datauser = json.decode(response.body);
    return datauser;
  }

  Future<List> getReview() async //retrieve all review data from server
  {
    final response = await http.post(url + "getRating2.php");
    var reviewData = json.decode(response.body);
    return reviewData;
  }

  Future<List>
      bookData1; //Variable, to store unfiltered stories data after refresh the page

  Future<List> getWriter() async //retrieve all writer data from server
  {
    final response = await http.post(url + "getAllContributor.php");
    var contributor = json.decode(response.body);
    return contributor;
  }

  Future<List> getLowHighRating() async //retrieve all writer data from server
  {
    final response = await http.post(url + "getLowHighRating.php");
    var lowHighRating = json.decode(response.body);
    return lowHighRating;
  }

  Future<List>
      getLanguage() async //retrieve all languages are available on server
  {
    final response = await http.post(url + "getLanguage.php");
    var data = json.decode(response.body);
    return data;
  }

  bool connection;

  //check internet connection
  void checkconnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = true;
      }
    } on SocketException catch (_) {
      connection = false;
    }
    setState(() {
      //something like refresh page, to notify the variable had make changes
    });
  }

  @override
  void initState() {
    //this function will run when the page start.
    checkconnection();

    super.initState();
    bookData1 = db.getStories(widget
        .childrenID); //widget.children. Means using the object in _LoadBookState. The data of the object are passed from previous pages.
  }

  @override
  Widget build(BuildContext context) {
    
    return new AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        //starting of data retrieving
        body: new FutureBuilder<List>(
          future: bookData1,
          builder: (context, snapshot5) {
            
            if (snapshot5.hasData) {
              collection = snapshot5.data; //copy all the data into the list
              return connection == true
                  ? new FutureBuilder<List>(
                      //if equal to true then continue retrieve other data
                      future: getStories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          bookData = snapshot.data;
                          return new FutureBuilder<List>(
                            future: getLowHighRating(),
                            builder: (context, lowHigh) {
                              if (lowHigh.hasData) {
                               
                                bookDataR = [];
                                for (int i = 0; i < lowHigh.data.length; i++) {
                                  if (lowHigh.data[i]
                                          ['RemovedRecommendStatus'] ==
                                      'Recommend') {
                                    for (int j = 0; j < bookData.length; j++) {
                                      if (lowHigh.data[i]['storybookId'] ==
                                          bookData[j]['storybookID']) {
                                        bookDataR.add(bookData[j]);
                                        break;
                                      }
                                    }
                                  }
                                }

                                bookDataL = [];
                                for (int i = bookData.length - 1; i >= 0; i--) {
                                  var parsedDate = DateTime.parse(
                                      bookData[i]['PublishedDate']);
                                  var date = DateTime.now()
                                      .subtract(new Duration(days: 10));

                                  if (date.isBefore(parsedDate)) {
                                    //print(bookData[i]['dateOfCreation'].toString());
                                    bookDataL.add(bookData[i]);
                                  }
                                }

                                return new FutureBuilder<List>(
                                    future: getFollowing(),
                                    builder: (context, snapshot8) {
                                      if (snapshot8.hasData)
                                        following = snapshot8.data;

                                      return new FutureBuilder<List>(
                                          future:
                                              db.getStats(widget.childrenID),
                                          builder: (context, statsFuture) {
                                            if (statsFuture.hasData)
                                              stats = statsFuture.data;

                                            return new FutureBuilder<List>(
                                                future: getReview(),
                                                builder: (context, snapshot6) {
                                                  if (snapshot6.hasData)
                                                    review = snapshot6.data;

                                                  return new FutureBuilder<
                                                      List>(
                                                    future: getWriter(),
                                                    builder:
                                                        (context, snapshot2) {
                                                      if (snapshot2.hasData) {
                                                        contributor =
                                                            snapshot2.data;
                                                        return new FutureBuilder<
                                                                List>(
                                                            future: db.getLanguage(
                                                                widget
                                                                    .childrenID), //start by "db." means retrieve data from local database
                                                            //retrieve children's selected languages from languagePreferred table
                                                            builder: (context,
                                                                snapshot3) {
                                                              languageList =
                                                                  snapshot3
                                                                      .data;

                                                              if (snapshot3
                                                                  .hasData) {
                                                                bookList = [];
                                                                for (int i = 0;
                                                                    i <
                                                                        languageList
                                                                            .length;
                                                                    i++) {
                                                                  //children selected languages.
                                                                  //filtering stories based on languages
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          bookData
                                                                              .length;
                                                                      j++) {
                                                                    //if match children's preferred languages

                                                                    if (languageList[i]
                                                                            .languageCode ==
                                                                        bookData[j]
                                                                            [
                                                                            'languageCode']) {
                                                                      bookList.add(
                                                                          bookData[
                                                                              j]);
                                                                    }
                                                                  }
                                                                }
                                                                bookList2 = [];
                                                                for (int i = 0;
                                                                    i <
                                                                        languageList
                                                                            .length;
                                                                    i++) {
                                                                  //children selected languages.
                                                                  //filtering stories based on languages
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          bookDataR
                                                                              .length;
                                                                      j++) {
                                                                    //if match children's preferred languages

                                                                    if (languageList[i]
                                                                            .languageCode ==
                                                                        bookDataR[j]
                                                                            [
                                                                            'languageCode']) {
                                                                      bookList2.add(
                                                                          bookDataR[
                                                                              j]);
                                                                    }
                                                                  }
                                                                }
                                                                bookList3 = [];
                                                                for (int i = 0;
                                                                    i <
                                                                        languageList
                                                                            .length;
                                                                    i++) {
                                                                  //children selected languages.
                                                                  //filtering stories based on languages
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          bookDataL
                                                                              .length;
                                                                      j++) {
                                                                    //if match children's preferred languages

                                                                    if (languageList[i]
                                                                            .languageCode ==
                                                                        bookDataL[j]
                                                                            [
                                                                            'languageCode']) {
                                                                      bookList3.add(
                                                                          bookDataL[
                                                                              j]);
                                                                    }
                                                                  }
                                                                }

                                                                return new FutureBuilder<
                                                                    List>(
                                                                  future:
                                                                      getLanguage(),
                                                                  builder: (context,
                                                                      snapshot4) {
                                                                    if (snapshot4
                                                                        .hasData) {
                                                                      languageData =
                                                                          snapshot4
                                                                              .data;
                                                                      return new Book_list(
                                                                          stats:
                                                                              stats,
                                                                          bookData:
                                                                              bookList,
                                                                          bookDataR:
                                                                              bookList2,
                                                                          bookDataL:
                                                                              bookList3,
                                                                          review:
                                                                              review,
                                                                          following:
                                                                              following,
                                                                          contributor:
                                                                              contributor,
                                                                          childrenID: widget
                                                                              .childrenID,
                                                                          collection:
                                                                              collection,
                                                                          languageData:
                                                                              languageData,
                                                                       
                                                                          childData: widget
                                                                              .childData,
                                                                          bookData1:
                                                                              bookData1);
                                                                    }
                                                                    return SpinKitThreeBounce(
                                                                        color: Colors
                                                                            .blue);
                                                                  },
                                                                );
                                                              }
                                                              return SpinKitThreeBounce(
                                                                  color: Colors
                                                                      .blue);
                                                            });
                                                      }
                                                      return SpinKitThreeBounce(
                                                          color: Colors.blue);
                                                    },
                                                  );
                                                });
                                          });
                                    });
                              
                              }
                              return SpinKitThreeBounce(color: Colors.blue);
                            },
                          );
                        
                        }
                        return SpinKitThreeBounce(color: Colors.blue);
                      },
                    )
                  : Book_list(
                      childrenID: widget.childrenID,
                      collection: collection,
                      stats: stats,
                    );
            }
            return SpinKitThreeBounce(color: Colors.blue);
          },
        ),
      ),
    );
  }
}

class Book_list extends StatefulWidget {
  Children childData;
  List bookData,
      bookDataR,
      contributor,
      collection,
      languageData,
      bookDataL,
      following,
      stats,
      review;
  String childrenID;

  Future<List> bookData1;

  @override
  Book_list(
      {Key key,
      this.stats,
      this.childData,
      this.following,
      this.childrenID,
      this.collection,

      this.review,
      this.bookData,
      this.contributor,
      this.languageData,
      this.bookData1,
      this.bookDataR,
      this.bookDataL})
      : super(key: key);
  Book_list_state createState() => new Book_list_state();
}

class Book_list_state extends State<Book_list>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PageController _pageController = new PageController();
  Color left = Colors.black;
  Color right = Colors.white;
  List storycollection = [];
  List languageAvailable = [];
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions;
  bool isReplay = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    //Only potrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    checkconnection();
    super.initState();
  }

  String url = 'http://i2hub.tarc.edu.my:8887/mmsr/';

  bool connection;
  void checkconnection() async {
    print(widget.childData.children_image);
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = true;
      }
    } on SocketException catch (_) {
      connection = false;
    }
    setState(() {});
  }

  void checkconnection2() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = true;
        showInSnackBar();
      }
    } on SocketException catch (_) {
      connection = false;
      showInSnackBar();
    }
    setState(() {});
  }

  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createBookList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(IconicIcons.cancel),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Load()),
                (Route<dynamic> route) => false);
            //navigate back to homepage and remove all route history
          },
        ),
        actions: <Widget>[
          _selectedIndex == 0 || _selectedIndex == 1
              ? IconButton(
                  // refresh Button
                  icon: const Icon(IconicIcons.loop),
                  tooltip: 'Refresh',
                  onPressed: () {
                    setState(
                      () {
                        checkconnection2();
                        var db = DBHelper();
                        connection == true //advance if else statement
                            //'?' if the statement is true
                            ? widget.bookData1 = db.getStories(widget
                                .childrenID) //start by "db." means retrieve data from local database.
                            //if internet available then call getStories() with children id to retrieve data
                            //':' else                                    and store it into the bookData1 variable.
                            : print(connection);
                      },
                    );
                  },
                )
              : SizedBox(),
        ],
      ),
      key: _scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SizedBox(
                height: 30, child: Image.asset('assets/img/gallery.png')),
            title: Text('Gallery'),
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
                height: 30, child: Image.asset('assets/img/following.png')),
            title: Text('Following'),
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
                height: 30, child: Image.asset('assets/img/downloads.png')),
            title: Text('Downloads'),
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
                height: 30, child: Image.asset('assets/img/stats.png')),
            title: Text('Stats'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions = <Widget>[
              _buildLibrary(context),
              _buildFollow(context),
              _buildCollection(context),
              _buildStats(context),
            ]),
      ),
    );
  }

  void showInSnackBar() {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        connection == true ? "Refresh successfully" : "No Internet Connection",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: connection == true ? Colors.green : Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildLibrary(BuildContext context) {
    return connection == false
        ? SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Gallery",
                              style: TextStyle(
                                  letterSpacing: -1.5,
                                  fontFamily: 'SourceSansBold',
                                  fontSize: 40),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 8),
                              Image.asset(
                                "assets/img/error.png",
                                fit: BoxFit.cover,
                              ),
                              Text(
                                "No Internet Collection!",
                                style: TextStyle(
                                    fontFamily: "WorkSansBold", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : widget.bookData.length == 0 // else if
            ? SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      letterSpacing: -1.5,
                                      fontFamily: 'SourceSansBold',
                                      fontSize: 40),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              8),
                                  Image.asset(
                                    "assets/img/sorry.png",
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    "Ops! No storybooks found.",
                                    style: TextStyle(
                                        fontFamily: "WorkSansBold",
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Color(0xFF2196F3),
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Gallery",
                                    style: TextStyle(
                                        letterSpacing: -1.5,
                                        color: Colors.white,
                                        fontFamily: 'SourceSansBold',
                                        fontSize: 40),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SearchPage(
                                                childData: widget.childData,
                                                review: widget.review,
                                                bookData: widget.bookData,
                                                contributor: widget.contributor,
                                                languageData:
                                                    widget.languageData,
                                                childrenID: widget.childrenID,
                                              )),
                                    );
                                  },
                                  child: new Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    height: 60,
                                    color: Colors.white,
                                    child: new Row(children: [
                                      Icon(IconicIcons.search),
                                      Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: Text(
                                          "Search",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'SourceSansRegular'),
                                        ),
                                      ),
                                    ]),
                                  )),
                              SizedBox(height: 10),
                              widget.bookDataR.length != 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Editor's Choice",
                                          style: TextStyle(
                                              letterSpacing: -1.5,
                                              fontFamily: 'SourceSansBold',
                                              color: const Color(0xffffffff),
                                              fontSize: 26),
                                        ),
                                        IconButton(
                                            // refresh Button
                                            icon: const Icon(
                                                IconicIcons.article_alt),
                                            iconSize: 20,
                                            tooltip: 'View more',
                                            color: Colors.white,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookTab(
                                                          childData:
                                                              widget.childData,
                                                          appBarTitle:
                                                              "Editor's Choice",
                                                          review: widget.review,
                                                          bookData:
                                                              widget.bookData,
                                                          childrenID:
                                                              widget.childrenID,
                                                          bookDataRoL:
                                                              widget.bookDataR,
                                                          contributor: widget
                                                              .contributor,
                                                          languageData: widget
                                                              .languageData,
                                                        )),
                                              );
                                            }),
                                      ],
                                    )
                                  : Container(),
                              widget.bookDataR.length != 0
                                  ? SizedBox(height: 10)
                                  : Container(),
                              widget.bookDataR.length != 0
                                  ? Container(
                                      height: 220,
                                      child: Swiper(
                                        autoplay: widget.bookDataR.length == 1
                                            ? false
                                            : true,
                                        loop: widget.bookDataR.length == 1
                                            ? false
                                            : true,
                                        scale: 0.5,
                                        viewportFraction: 0.95,
                                        itemCount: widget.bookDataR == null
                                            ? 0
                                            : widget.bookDataR.length,
                                        pagination: new SwiperPagination(
                                          builder:
                                              new DotSwiperPaginationBuilder(
                                                  color: Colors.grey,
                                                  activeColor:
                                                      Color(0xFF2196F3)),
                                        ),
                                        itemBuilder: (context, i) {
                                          String language;
                                          //To check what is the language of the story.
                                          for (int j = 0;
                                              j < widget.languageData.length;
                                              j++) {
                                            if (widget.bookDataR[i]
                                                    ['languageCode'] ==
                                                widget.languageData[j]
                                                    ['languageCode']) {
                                              language = widget.languageData[j]
                                                  ['languageDesc'];
                                            }
                                          }
                                          String name = '';
                                          String id = '';
                                          //To check who is the writer for the story.
                                          for (int j = 0;
                                              j < widget.contributor.length;
                                              j++) {
                                            if (widget.bookDataR[i]
                                                    ['ContributorID'] ==
                                                widget.contributor[j]
                                                    ['ContributorID']) {
                                              id = widget.contributor[j]
                                                  ['ContributorID'];
                                              name =
                                                  widget.contributor[j]['Name'];
                                            }
                                          }
                                          Uint8List bytes = base64Decode(widget
                                              .bookDataR[i]['storybookCover']);

                                          int bookIndex;
                                          for (int j = 0;
                                              j < widget.bookData.length;
                                              j++) {
                                            if (widget.bookData[j]
                                                        ['storybookID'] ==
                                                    widget.bookDataR[i]
                                                        ['storybookID'] &&
                                                widget.bookDataR[i]
                                                        ['languageCode'] ==
                                                    widget.bookData[j]
                                                        ['languageCode']) {
                                              bookIndex = j;
                                              break;
                                            }
                                          }

                                          bool rating = false;
                                          for (int j = 0;
                                              j < widget.review.length;
                                              j++) {
                                            if (widget.review[j]
                                                        ['storybookID'] ==
                                                    widget.bookDataR[i]
                                                        ['storybookID'] &&
                                                widget.review[j]
                                                        ['languageCode'] ==
                                                    widget.bookDataR[i]
                                                        ['languageCode']) {
                                              rating = true;
                                              break;
                                            }
                                          }
                                          return Container(
                                            //width: MediaQuery.of(context).size.width,
                                            child: GestureDetector(
                                              onTap: () {
                                                print(bookIndex.toString());
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoadDetail(
                                                              childData: widget
                                                                  .childData,
                                                              reviewAll: widget
                                                                  .review,
                                                              languageData: widget
                                                                  .languageData,
                                                              contributorList:
                                                                  widget
                                                                      .contributor,
                                                              bookData: widget
                                                                  .bookData,
                                                              index: bookIndex,
                                                              contributor: name,
                                                              contributorID: id,
                                                              childrenID: widget
                                                                  .childrenID,
                                                              language:
                                                                  language)),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Center(
                                                        child: Image(
                                                          gaplessPlayback: true,
                                                          image: MemoryImage(
                                                              bytes),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Column(
                                                        children: <Widget>[
                                                          SizedBox(height: 115),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      0.8),
                                                            ),
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 40,
                                                                    right: 40),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  child: Text(
                                                                    '${widget.bookDataR[i]['storybookTitle']}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            'SourceSansBold'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'by $name',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'SourceSansLight',
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                                SizedBox(
                                                                    height: 3),
                                                                rating == true
                                                                    ? Container(
                                                                        child:
                                                                            FlutterRatingBarIndicator(
                                                                          itemPadding:
                                                                              EdgeInsets.only(right: 1),
                                                                          rating: double.parse(widget.bookDataR[i]['rating']) == null
                                                                              ? 0
                                                                              : double.parse(widget.bookDataR[i]['rating']),
                                                                          itemCount:
                                                                              5,
                                                                          itemSize:
                                                                              15.0,
                                                                          emptyColor:
                                                                              Color(0xFF000000),
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "(No rating yet)",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            fontFamily:
                                                                                'SourceSansRegular'),
                                                                        overflow:
                                                                            TextOverflow.clip,
                                                                        softWrap:
                                                                            false,
                                                                      ),
                                                                SizedBox(
                                                                    height: 3),
                                                                Text(
                                                                  language,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontFamily:
                                                                          'SourceSansLight'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                  softWrap:
                                                                      false,
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(),
                              widget.bookDataR.length != 0
                                  ? SizedBox(height: 10)
                                  : Container(),
                              widget.bookDataL.length != 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "What's New",
                                          style: TextStyle(
                                              letterSpacing: -1.5,
                                              fontFamily: 'SourceSansBold',
                                              color: const Color(0xffffffff),
                                              fontSize: 26),
                                        ),
                                        IconButton(
                                            // refresh Button
                                            icon: const Icon(
                                                IconicIcons.article_alt),
                                            iconSize: 20,
                                            tooltip: 'View more',
                                            color: Colors.white,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookTab(
                                                          childData:
                                                              widget.childData,
                                                          appBarTitle:
                                                              "What's New",
                                                          bookData:
                                                              widget.bookData,
                                                          review: widget.review,
                                                          childrenID:
                                                              widget.childrenID,
                                                          bookDataRoL:
                                                              widget.bookDataL,
                                                          contributor: widget
                                                              .contributor,
                                                          languageData: widget
                                                              .languageData,
                                                        )),
                                              );
                                            }),
                                      ],
                                    )
                                  : Container(),
                              widget.bookDataL.length != 0
                                  ? SizedBox(height: 10)
                                  : Container(),
                              widget.bookDataL.length != 0
                                  ? Container(
                                      height: 220,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: widget.bookDataL == null
                                            ? 0
                                            : widget.bookDataL.length,
                                        itemBuilder: (context, i) {
                                          String language;
                                          //To check what is the language of the story.
                                          for (int j = 0;
                                              j < widget.languageData.length;
                                              j++) {
                                            if (widget.bookDataL[i]
                                                    ['languageCode'] ==
                                                widget.languageData[j]
                                                    ['languageCode']) {
                                              language = widget.languageData[j]
                                                  ['languageDesc'];
                                            }
                                          }
                                          String name = '';
                                          String id = '';
                                          //To check who is the writer for the story.
                                          for (int j = 0;
                                              j < widget.contributor.length;
                                              j++) {
                                            if (widget.bookDataL[i]
                                                    ['ContributorID'] ==
                                                widget.contributor[j]
                                                    ['ContributorID']) {
                                              id = widget.contributor[j]
                                                  ['ContributorID'];
                                              name =
                                                  widget.contributor[j]['Name'];
                                            }
                                          }

                                          Uint8List bytes = base64Decode(widget
                                              .bookDataL[i]['storybookCover']);

                                          int bookIndex;
                                          for (int j = 0;
                                              j < widget.bookData.length;
                                              j++) {
                                            if (widget.bookData[j]
                                                        ['storybookID'] ==
                                                    widget.bookDataL[i]
                                                        ['storybookID'] &&
                                                widget.bookDataL[i]
                                                        ['languageCode'] ==
                                                    widget.bookData[j]
                                                        ['languageCode']) {
                                              bookIndex = j;
                                              break;
                                            }
                                          }

                                          bool rating = false;
                                          for (int j = 0;
                                              j < widget.review.length;
                                              j++) {
                                            if (widget.review[j]
                                                        ['storybookID'] ==
                                                    widget.bookDataL[i]
                                                        ['storybookID'] &&
                                                widget.review[j]
                                                        ['languageCode'] ==
                                                    widget.bookDataL[i]
                                                        ['languageCode']) {
                                              rating = true;
                                              break;
                                            }
                                          }
                                          return Container(
                                            padding: EdgeInsets.all(5),
                                            width: 120,
                                            //color: Color(0xFFF1F1F1),
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => LoadDetail(
                                                            childData: widget
                                                                .childData,
                                                            reviewAll:
                                                                widget.review,
                                                            languageData: widget
                                                                .languageData,
                                                            contributorList:
                                                                widget
                                                                    .contributor,
                                                            bookData:
                                                                widget.bookData,
                                                            index: bookIndex,
                                                            contributor: name,
                                                            childrenID: widget
                                                                .childrenID,
                                                            contributorID: id,
                                                            language:
                                                                language)),
                                                  );
                                                },
                                                child: Card(
                                                  color: Colors.transparent,
                                                  elevation: 0,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                          color: Colors.grey,
                                                        )),
                                                        child: FadeInImage(
                                                          //Fade animation
                                                          fit: BoxFit.cover,
                                                          height: 100,
                                                          width: 100,
                                                          image: MemoryImage(
                                                              bytes),
                                                          placeholder: MemoryImage(
                                                              kTransparentImage),
                                                        ),
                                                      ),
                                                      Container(
                                                        // padding: EdgeInsets.all(left: 20),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(height: 3),
                                                            Container(
                                                              height: 42,
                                                              child: Text(
                                                                '${widget.bookDataL[i]['storybookTitle']}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        'SourceSansRegular'),
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                            Text(
                                                              'by $name',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'SourceSansLight',
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                            ),
                                                            SizedBox(height: 3),
                                                            rating == true
                                                                ? Container(
                                                                    child:
                                                                        FlutterRatingBarIndicator(
                                                                      itemPadding:
                                                                          EdgeInsets.only(
                                                                              right: 1),
                                                                      rating: double.parse(widget.bookData[i]['rating']) ==
                                                                              null
                                                                          ? 0
                                                                          : double.parse(widget.bookDataL[i]
                                                                              [
                                                                              'rating']),
                                                                      itemCount:
                                                                          5,
                                                                      itemSize:
                                                                          15.0,
                                                                      emptyColor:
                                                                          Color(
                                                                              0xFF000000),
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    "(No rating yet)",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            'SourceSansRegular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                    softWrap:
                                                                        false,
                                                                  ),
                                                            SizedBox(height: 3),
                                                            Text(
                                                              language,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'SourceSansLight'),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              softWrap: false,
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(),
                              widget.bookDataL.length != 0
                                  ? SizedBox(height: 10)
                                  : Container(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "All Storybooks",
                                    style: TextStyle(
                                        letterSpacing: -1.5,
                                        fontFamily: 'SourceSansBold',
                                        color: const Color(0xffffffff),
                                        fontSize: 26),
                                  ),
                                  IconButton(
                                      // refresh Button
                                      icon: const Icon(IconicIcons.article_alt),
                                      iconSize: 20,
                                      tooltip: 'View more',
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BookTab(
                                                    childData: widget.childData,
                                                    appBarTitle:
                                                        "All Storybooks",
                                                    bookData: widget.bookData,
                                                    review: widget.review,
                                                    childrenID:
                                                        widget.childrenID,
                                                    bookDataRoL:
                                                        widget.bookData,
                                                    contributor:
                                                        widget.contributor,
                                                    languageData:
                                                        widget.languageData,
                                                  )),
                                        );
                                      }),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.bookData == null
                                      ? 0
                                      : widget.bookData.length,
                                  itemBuilder: (context, i) {
                                    String language;
                                    //To check what is the language of the story.
                                    for (int j = 0;
                                        j < widget.languageData.length;
                                        j++) {
                                      if (widget.bookData[i]['languageCode'] ==
                                          widget.languageData[j]
                                              ['languageCode']) {
                                        language = widget.languageData[j]
                                            ['languageDesc'];
                                      }
                                    }
                                    String name = '';
                                    String id = '';
                                    //To check who is the writer for the story.
                                    for (int j = 0;
                                        j < widget.contributor.length;
                                        j++) {
                                      if (widget.bookData[i]['ContributorID'] ==
                                          widget.contributor[j]
                                              ['ContributorID']) {
                                        id = widget.contributor[j]
                                            ['ContributorID'];
                                        name = widget.contributor[j]['Name'];
                                      }
                                    }

                                    Uint8List bytes = base64Decode(
                                        widget.bookData[i]['storybookCover']);

                                    bool rating = false;
                                    for (int j = 0;
                                        j < widget.review.length;
                                        j++) {
                                      if (widget.review[j]['storybookID'] ==
                                              widget.bookData[i]
                                                  ['storybookID'] &&
                                          widget.review[j]['languageCode'] ==
                                              widget.bookData[i]
                                                  ['languageCode']) {
                                        rating = true;
                                        break;
                                      }
                                    }
                                    return Container(
                                      padding: EdgeInsets.all(5),
                                      width: 120,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoadDetail(
                                                          childData:
                                                              widget.childData,
                                                          reviewAll:
                                                              widget.review,
                                                          languageData: widget
                                                              .languageData,
                                                          contributorList:
                                                              widget
                                                                  .contributor,
                                                          bookData:
                                                              widget.bookData,
                                                          index: i,
                                                          contributor: name,
                                                          contributorID: id,
                                                          childrenID:
                                                              widget.childrenID,
                                                          language: language)),
                                            );
                                          },
                                          child: Card(
                                            color: Colors.transparent,
                                            elevation: 0,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                    color: Colors.grey,
                                                  )),
                                                  child: FadeInImage(
                                                    //Fade animation
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: 100,
                                                    image: MemoryImage(bytes),
                                                    placeholder: MemoryImage(
                                                        kTransparentImage),
                                                  ),
                                                ),
                                                Container(
                                                  // padding: EdgeInsets.all(left: 20),
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(height: 3),
                                                      Container(
                                                        height: 42,
                                                        child: Text(
                                                          '${widget.bookData[i]['storybookTitle']}',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'SourceSansRegular'),
                                                          overflow:
                                                              TextOverflow.clip,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                      Text(
                                                        'by $name',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'SourceSansLight',
                                                        ),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                      SizedBox(height: 3),
                                                      rating == true
                                                          ? Container(
                                                              child:
                                                                  FlutterRatingBarIndicator(
                                                                itemPadding:
                                                                    EdgeInsets.only(
                                                                        right:
                                                                            1),
                                                                rating: double.parse(widget.bookData[i]
                                                                            [
                                                                            'rating']) ==
                                                                        null
                                                                    ? 0
                                                                    : double.parse(
                                                                        widget.bookData[i]
                                                                            [
                                                                            'rating']),
                                                                itemCount: 5,
                                                                itemSize: 15.0,
                                                                emptyColor: Color(
                                                                    0xFF000000),
                                                              ),
                                                            )
                                                          : Text(
                                                              "(No rating yet)",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'SourceSansRegular'),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              softWrap: false,
                                                            ),
                                                      SizedBox(height: 3),
                                                      Text(
                                                        language,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'SourceSansLight'),
                                                        overflow:
                                                            TextOverflow.clip,
                                                        softWrap: false,
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }

  void createBookList() {
    //is a function filter all different languages stories by story title.
    String OldStoryID = "";
    storycollection = []; // to store all story with different id
    languageAvailable = []; //to store stories' available language.
    for (int i = 0; i < widget.collection.length; i++) {
      if (storycollection.length == 0) {
        //Starting, store the first story details.
        storycollection.add(widget.collection[0]);
        languageAvailable.add(widget.collection[0]);
        OldStoryID = storycollection[0].story_id;
      } else {
        if (OldStoryID == widget.collection[i].story_id) {
          //if story id is the same means is same story but different langauges.
          //So, record all available languages and story id.
          //In "widget.collection" has all story details, but we only need story id and language.
          languageAvailable.add(widget.collection[i]);
        } else {
          //if the story id does not same anymore
          storycollection.add(
              widget.collection[i]); //new story details will be add into list.
          languageAvailable.add(widget.collection[i]); //the new story language
          OldStoryID =
              widget.collection[i].story_id; //the new story id use to compare.
        }
      }
    }
  }

  Widget _buildCollection(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Downloads",
                        style: TextStyle(
                            letterSpacing: -1.5,
                            fontFamily: 'SourceSansBold',
                            fontSize: 40),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  storycollection.length == 0
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 8),
                              Image.asset(
                                "assets/img/empty.png",
                                fit: BoxFit.cover,
                              ),
                              Text(
                                "Empty! Download now at Gallery",
                                style: TextStyle(
                                    fontFamily: "WorkSansBold", fontSize: 20),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchDownload(
                                        childData: widget.childData,
                                        storyData: storycollection,
                                        languageAvailable: languageAvailable,
                                        childrenID: widget.childrenID,
                                      )),
                            );
                          },
                          child: new Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            height: 60,
                            color: Color(0xFFF1F1F1),
                            child: new Row(children: [
                              Icon(IconicIcons.search),
                              Container(
                                margin: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Search",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SourceSansRegular'),
                                ),
                              ),
                            ]),
                          )),
                  SizedBox(height: 10),
                  Container(
                    color: Color(0xFFF1F1F1),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: storycollection.length,
                        itemBuilder: (context, i) {
                          List<Widget> list = new List<Widget>();
                          for (int j = 0; j < languageAvailable.length; j++) {
                            //languageAvailable has stored all the story id and languages.
                            if (languageAvailable[j].story_id ==
                                storycollection[i]
                                    .story_id) //to find out all available languages of the story.
                            {
                              //add language description into a list for display purpose.
                              list.add(
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 5, top: 5, bottom: 5),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    languageAvailable[j].languageDesc,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'SourceSansRegular'),
                                  ),
                                ),
                              );
                            }
                          }
                          Uint8List bytes =
                              base64Decode(storycollection[i].story_cover);

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
                                                placeholder: MemoryImage(
                                                    kTransparentImage),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20, right: 20),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      storycollection[i]
                                                          .story_title,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'SourceSansBold',
                                                          fontSize: 20),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12, right: 12),
                                                    child: Container(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Wrap(
                                                            alignment:
                                                                WrapAlignment
                                                                    .start,
                                                            children: list))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoadContent(
                                                  childData: widget.childData,
                                                  storyID: storycollection[i]
                                                      .story_id,
                                                  childrenID: widget.childrenID,
                                                  storyTitle: storycollection[i]
                                                      .story_title,
                                                  storyLanguage:
                                                      storycollection[i]
                                                          .languageCode,
                                                )),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  bottom: -15,
                                  child: Container(
                                    width: 30.0,
                                    child: IconButton(
                                      icon: Icon(Icons.delete_outline),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delete ' +
                                                  storycollection[i]
                                                      .story_title),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Are you sure?'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('No'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text('Yes'),
                                                  onPressed: () {
                                                    choiceAction(1, i);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                i != storycollection.length - 1
                                    ? Positioned(
                                        bottom: -10,
                                        left: 5,
                                        child: Container(
                                          height: 1.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          color: Color(0xFFB5B5B5),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollow(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Following",
                        style: TextStyle(
                            letterSpacing: -1.5,
                            fontFamily: 'SourceSansBold',
                            fontSize: 40),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  connection == false
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 8),
                              Image.asset(
                                "assets/img/error.png",
                                fit: BoxFit.cover,
                              ),
                              Text(
                                "No Internet Collection!",
                                style: TextStyle(
                                    fontFamily: "WorkSansBold", fontSize: 20),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchFollow(
                                        childData: widget.childData,
                                        contributor: widget.contributor,
                                        review: widget.review,
                                        languageData: widget.languageData,
                                        childrenID: widget.childrenID,
                                      )),
                            );
                          },
                          child: new Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            height: 60,
                            color: Color(0xFFF1F1F1),
                            child: new Row(children: [
                              Icon(IconicIcons.search),
                              Container(
                                margin: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Search",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'SourceSansRegular'),
                                ),
                              ),
                            ]),
                          )),
                  SizedBox(height: 10),
                  connection == false
                      ? Container()
                      : widget.following.length == 0
                          ? Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12),
                                  Image.asset(
                                    "assets/img/empty.png",
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    "Empty! Follow a writer now",
                                    style: TextStyle(
                                        fontFamily: "WorkSansBold",
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              color: Color(0xFFF1F1F1),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.following.length,
                                  itemBuilder: (context, i) {
                                    List contributor = [];
                                    String date = '';
                                    for (int j = 0;
                                        j < widget.following.length;
                                        j++) {
                                      for (int k = 0;
                                          k < widget.contributor.length;
                                          k++) {
                                        if (widget.contributor[k]
                                                ['ContributorID'] ==
                                            widget.following[j]
                                                ['ContributorID']) {
                                          date = widget.following[j]
                                              ['follow_date'];
                                          contributor
                                              .add(widget.contributor[k]);
                                          break;
                                        }
                                      }
                                    }
                                    // Uint8List bytes = base64Decode(
                                    //     storycollection[i].story_cover);

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      padding: EdgeInsets.only(
                                          top: 5, right: 5, left: 5),
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
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        /* child: FadeInImage(
                                                          fit: BoxFit.cover,
                                                          height: 100,
                                                          width: 100,
                                                          image: MemoryImage(
                                                              bytes),
                                                          placeholder: MemoryImage(
                                                              kTransparentImage), ),*/
                                                        height: 100,
                                                        width: 100,
                                                        child: Image.asset(
                                                            "assets/img/fox.png",
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    right: 20),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                contributor[i]
                                                                    ['Name'],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'SourceSansBold',
                                                                    fontSize:
                                                                        20),
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    right: 20),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                contributor[i][
                                                                        'followers'] +
                                                                    " Followers",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'SourceSansRegular',
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    right: 20),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                'Followed since ' +
                                                                    date.toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'SourceSansLight',
                                                                    fontSize:
                                                                        15),
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WriterDetails(
                                                            childData: widget
                                                                .childData,
                                                            writer: widget
                                                                .contributor,
                                                            languageData: widget
                                                                .languageData,
                                                            review:
                                                                widget.review,
                                                            childrenID: widget
                                                                .childrenID,
                                                            index: widget
                                                                .contributor
                                                                .indexOf(
                                                                    contributor[
                                                                        i]),
                                                            contributorID:
                                                                contributor[i][
                                                                    'ContributorID'],
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            right: 5,
                                            bottom: -15,
                                            child: Container(
                                              width: 30.0,
                                              child: IconButton(
                                                icon:
                                                    Icon(Icons.delete_outline),
                                                tooltip: 'Unfollow',
                                                onPressed: () {
                                                  showDialog<void>(
                                                    context: context,
                                                    barrierDismissible:
                                                        false, // user must tap button!
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Unfollow ' +
                                                                contributor[i]
                                                                    ['Name']),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: ListBody(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Are you sure?'),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('No'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          FlatButton(
                                                            child: Text('Yes'),
                                                            onPressed: () {
                                                              unfollowWriter(
                                                                  1,
                                                                  contributor[i]
                                                                      [
                                                                      'ContributorID']);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          i != widget.following.length - 1
                                              ? Positioned(
                                                  bottom: -10,
                                                  left: 5,
                                                  child: Container(
                                                    height: 1.0,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            50,
                                                    color: Color(0xFFB5B5B5),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0xFF2196F3),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Stats",
                          style: TextStyle(
                              letterSpacing: -1.5,
                              color: Colors.white,
                              fontFamily: 'SourceSansBold',
                              fontSize: 40),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      height: 160,
                      child: Image.asset(
                        widget.childData.children_image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.childData.children_name,
                        style: TextStyle(
                            letterSpacing: -1.5,
                            color: Colors.white,
                            fontFamily: 'SourceSansRegular',
                            fontSize: 30),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Your Medals',
                        style: TextStyle(
                            letterSpacing: -0.5,
                            color: Colors.white,
                            fontFamily: 'SourceSansRegular',
                            fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              child: Image.asset(
                                'assets/img/readFive.png',
                                color: widget.stats[0].num_read < 5
                                    ? Color(0xFFcfcfcf)
                                    : null,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 100,
                              child: Text(
                                'Read 5 books',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: -0.5,
                                    color: widget.stats[0].num_read < 5
                                        ? Color(0xFFcfcfcf)
                                        : Colors.white,
                                    fontFamily: 'SourceSansLight',
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              child: Image.asset(
                                'assets/img/downloadTen.png',
                                fit: BoxFit.cover,
                                color: widget.stats[0].num_download < 10
                                    ? Color(0xFFcfcfcf)
                                    : null,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 100,
                              child: Text(
                                'Download 10 books',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: -0.5,
                                    color: widget.stats[0].num_download < 10
                                        ? Color(0xFFcfcfcf)
                                        : Colors.white,
                                    fontFamily: 'SourceSansLight',
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              child: Image.asset(
                                'assets/img/rateFive.png',
                                color: widget.stats[0].num_rate < 5
                                    ? Color(0xFFcfcfcf)
                                    : null,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 100,
                              child: Text(
                                'Rate 5 books',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: -0.5,
                                    color: widget.stats[0].num_rate < 5
                                        ? Color(0xFFcfcfcf)
                                        : Colors.white,
                                    fontFamily: 'SourceSansLight',
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              child: Image.asset(
                                'assets/img/followFive.png',
                                fit: BoxFit.cover,
                                color: widget.stats[0].num_follow < 5
                                    ? Color(0xFFcfcfcf)
                                    : null,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 100,
                              child: Text(
                                'Follow 5 writers',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: -0.5,
                                    color: widget.stats[0].num_follow < 5
                                        ? Color(0xFFcfcfcf)
                                        : Colors.white,
                                    fontFamily: 'SourceSansLight',
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void choiceAction(int choice, int i) async {
    var db = DBHelper();
    //delete all details of the storybook id
    if (choice == 1) {
      //logging for delete storybook
      http.post(url + "addLogChildren(Reader).php", body: {
        'children_id': widget.childrenID,
        'title': 'Delete Storybook From Downloads',
        'description': widget.childrenID +
            ' has removed a storybook from downloads: ' +
            storycollection[i].story_id,
      });

      db.deleteBook(storycollection[i].story_id, widget.childrenID);
      db.deleteText(storycollection[i].story_id, widget.childrenID,
          storycollection[i].languageCode);
      db.deleteImage(storycollection[i].story_id, widget.childrenID);
      db.deleteOngoing(storycollection[i].story_id, widget.childrenID);
      setState(() {
        widget.collection.removeWhere(
            (item) => item.story_id == storycollection[i].story_id);
        storycollection = [];
        languageAvailable = [];
      });
    }
  }

  void unfollowWriter(int choice, String id) async {
    if (choice == 1) {
      http.post(url + "unfollowWriter.php", body: {
        'children_id': widget.childrenID,
        'ContributorID': id,
      });

      http.post(url + "addLogChildren(Reader).php", body: {
        'children_id': widget.childrenID,
        'title': 'Unfollow Contributor',
        'description':
            widget.childrenID + ' has unfollowed a contributor: ' + id,
      });

      setState(() {
        widget.following.removeWhere((item) =>
            item['ContributorID'] == id &&
            item['children_id'] == widget.childrenID);
      });
    }
  }
}

class BookTab extends StatefulWidget {
  List bookData, bookDataRoL, contributor, languageData, review;
  String childrenID, appBarTitle;
  Children childData;

  BookTab(
      {Key key,
      this.bookData,
      this.review,
      this.childData,
      this.childrenID,
      this.appBarTitle,
      this.contributor,
      this.languageData,
      this.bookDataRoL})
      : super(key: key);
  @override
  _BookTabState createState() => new _BookTabState();
}

class _BookTabState extends State<BookTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text(widget.appBarTitle),
        actions: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: itemWidth / itemHeight),
              itemCount:
                  widget.bookDataRoL == null ? 0 : widget.bookDataRoL.length,
              itemBuilder: (context, i) {
                String language;
                //To check what is the language of the story.
                for (int j = 0; j < widget.languageData.length; j++) {
                  if (widget.bookDataRoL[i]['languageCode'] ==
                      widget.languageData[j]['languageCode']) {
                    language = widget.languageData[j]['languageDesc'];
                  }
                }
                String name = '';
                String id = '';
                //To check who is the writer for the story.
                for (int j = 0; j < widget.contributor.length; j++) {
                  if (widget.bookDataRoL[i]['ContributorID'] ==
                      widget.contributor[j]['ContributorID']) {
                    id = widget.contributor[j]['ContributorID'];
                    name = widget.contributor[j]['Name'];
                  }
                }

                int bookIndex;
                for (int j = 0; j < widget.bookData.length; j++) {
                  if (widget.bookData[j]['storybookID'] ==
                          widget.bookDataRoL[i]['storybookID'] &&
                      widget.bookDataRoL[i]['languageCode'] ==
                          widget.bookData[j]['languageCode']) {
                    bookIndex = j;
                    break;
                  }
                }

                Uint8List bytes =
                    base64Decode(widget.bookDataRoL[i]['storybookCover']);

                bool rating = false;
                for (int j = 0; j < widget.review.length; j++) {
                  if (widget.review[j]['storybookID'] ==
                          widget.bookDataRoL[i]['storybookID'] &&
                      widget.review[j]['languageCode'] ==
                          widget.bookDataRoL[i]['languageCode']) {
                    rating = true;
                    break;
                  }
                }

                return Container(
                  //color: Color(0xFFF1F1F1),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoadDetail(
                                  childData: widget.childData,
                                  reviewAll: widget.review,
                                  languageData: widget.languageData,
                                  contributorList: widget.contributor,
                                  bookData: widget.bookData,
                                  index: bookIndex,
                                  contributor: name,
                                  contributorID: id,
                                  childrenID: widget.childrenID,
                                  language: language)),
                        );
                      },
                      child: Card(
                        color: Color(0xFFF1F1F1),
                        elevation: 0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: Colors.grey,
                              )),
                              child: FadeInImage(
                                //Fade animation
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                                image: MemoryImage(bytes),
                                placeholder: MemoryImage(kTransparentImage),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 3),
                                  Container(
                                    height: 42,
                                    child: Text(
                                      '${widget.bookDataRoL[i]['storybookTitle']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'SourceSansRegular'),
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    'by $name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'SourceSansLight',
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                  SizedBox(height: 3),
                                  rating == true
                                      ? Container(
                                          child: FlutterRatingBarIndicator(
                                            itemPadding:
                                                EdgeInsets.only(right: 1),
                                            rating: double.parse(
                                                        widget.bookDataRoL[i]
                                                            ['rating']) ==
                                                    null
                                                ? 0
                                                : double.parse(widget
                                                    .bookDataRoL[i]['rating']),
                                            itemCount: 5,
                                            itemSize: 15.0,
                                            emptyColor: Color(0xFF000000),
                                          ),
                                        )
                                      : Text(
                                          "(No rating yet)",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'SourceSansRegular'),
                                          overflow: TextOverflow.clip,
                                          softWrap: false,
                                        ),
                                  SizedBox(height: 3),
                                  Text(
                                    language,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'SourceSansLight'),
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  List bookData, contributor, languageData, review;
  String childrenID;
  Children childData;
  SearchPage(
      {Key key,
      this.bookData,
      this.childData,
      this.review,
      this.contributor,
      this.languageData,
      this.childrenID})
      : super(key: key);
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Storybook> story = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<Storybook>> getStories(
      String text) async //retrieve all stories from server
  {
    await Future.delayed(Duration(seconds: 1));
    story = [];
    for (int i = 0; i < widget.bookData.length; i++) {
      if (widget.bookData[i]['storybookTitle']
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase())) {
        story.add(Storybook(
            widget.bookData[i]['storybookID'],
            widget.bookData[i]['storybookTitle'],
            widget.bookData[i]['storybookCover'],
            widget.bookData[i]['storybookDesc'],
            widget.bookData[i]['storybookGenre'],
            widget.bookData[i]['PublishedDate'],
            widget.bookData[i]['status'],
            widget.bookData[i]['ContributorID'],
            widget.bookData[i]['languageCode'],
            i));
      }
    }
    return story;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text('Search for storybooks'),
        actions: <Widget>[],
      ),
      body: Container(
        child: SearchBar<Storybook>(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: getStories,
          minimumChars: 1,
          hintText: 'Enter the book title',
          onItemFound: (Storybook storybook, int index) {
            String language;
            //To check what is the language of the story.
            for (int j = 0; j < widget.languageData.length; j++) {
              if (story[index].languageCode ==
                  widget.languageData[j]['languageCode']) {
                language = widget.languageData[j]['languageDesc'];
              }
            }
            String name = '';
            String id = '';
            //To check who is the writer for the story.
            for (int j = 0; j < widget.contributor.length; j++) {
              if (story[index].contributor_id ==
                  widget.contributor[j]['ContributorID']) {
                id = widget.contributor[j]['ContributorID'];
                name = widget.contributor[j]['Name'];
              }
            }

            return ListTile(
              title: Text(storybook.story_title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text(storybook.story_desc),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Written by: " + name),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoadDetail(
                          childData: widget.childData,
                          reviewAll: widget.review,
                          languageData: widget.languageData,
                          contributorList: widget.contributor,
                          bookData: widget.bookData,
                          index: story[index].index,
                          contributor: name,
                          contributorID: id,
                          childrenID: widget.childrenID,
                          language: language)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SearchDownload extends StatefulWidget {
  List storyData, languageAvailable;
  String childrenID;
  Children childData;
  SearchDownload(
      {Key key,
      this.storyData,
      this.languageAvailable,
      this.childrenID,
      this.childData})
      : super(key: key);
  @override
  _SearchDownloadState createState() => new _SearchDownloadState();
}

class _SearchDownloadState extends State<SearchDownload> {
  List<Storybook> story = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<Storybook>> getStories(String text) async {
    await Future.delayed(Duration(seconds: 1));
    story = [];
    for (int i = 0; i < widget.storyData.length; i++) {
      if (widget.storyData[i].story_title
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase())) {
        story.add(Storybook(
            widget.storyData[i].story_id,
            widget.storyData[i].story_title,
            widget.storyData[i].story_cover,
            widget.storyData[i].download_date.toString(),
            widget.storyData[i].contributor_name,
            "",
            "",
            "",
            "",
            i));
      }
    }
    return story;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text('Search for storybooks'),
        actions: <Widget>[],
      ),
      body: Container(
        child: SearchBar<Storybook>(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: getStories,
          minimumChars: 1,
          hintText: 'Enter the book title',
          onItemFound: (Storybook storybook, int index) {
            return ListTile(
              title: Text(storybook.story_title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text("Download date: " + storybook.story_desc),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Written by: " + storybook.story_genre),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoadContent(
                            childData: widget.childData,
                            storyID: widget.storyData[storybook.index].story_id,
                            childrenID: widget.childrenID,
                            storyTitle:
                                widget.storyData[storybook.index].story_title,
                            storyLanguage:
                                widget.storyData[storybook.index].languageCode,
                          )),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SearchFollow extends StatefulWidget {
  List contributor, review, languageData;
  Children childData;
  String childrenID;
  SearchFollow(
      {Key key,
      this.childData,
      this.contributor,
      this.childrenID,
      this.review,
      this.languageData})
      : super(key: key);
  @override
  _SearchFollowState createState() => new _SearchFollowState();
}

class _SearchFollowState extends State<SearchFollow> {
  List con = [], num = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List> getWriters(String text) async {
    await Future.delayed(Duration(seconds: 1));
    con = [];
    num = [];
    for (int i = 0; i < widget.contributor.length; i++) {
      if (widget.contributor[i]['Name']
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase())) {
        con.add(widget.contributor[i]);
        num.add(widget.contributor.indexOf(widget.contributor[i]));
      }
    }
    return con;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text('Search for writers'),
        actions: <Widget>[],
      ),
      body: Container(
        child: SearchBar(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: getWriters,
          minimumChars: 1,
          hintText: "Enter the writer's name",
          onItemFound: (item, int index) {
            return ListTile(
              title: Text(con[index]['Name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text('Date of Birth: ' + con[index]['DOB'].toString()),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Followers: ' + con[index]['followers'].toString()),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WriterDetails(
                            childData: widget.childData,
                            writer: widget.contributor,
                            languageData: widget.languageData,
                            review: widget.review,
                            childrenID: widget.childrenID,
                            index: num[index],
                            contributorID: con[index]['ContributorID'],
                          )),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
