import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reader_mmsr/Model/StoryModel.dart';
import 'package:reader_mmsr/Model/Storybook.dart';
import 'package:reader_mmsr/localdatabase/Database.dart';
import 'package:reader_mmsr/style/theme.dart' as Theme;
import 'package:reader_mmsr/parent_ui/parental_gate.dart';
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
  String childrenID;
  int page;

  LoadBook({Key key, this.childrenID, this.page}) : super(key: key);
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
      review;
  String url = 'http://10.0.2.2/mmsr/';

  var db = DBHelper();
  List bookList = [], bookList2 = [], bookList3 = [];
  var languageList;

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
    var Contributor = json.decode(response.body);
    return Contributor;
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
        body: FutureBuilder<List>(
          future: bookData1,
          builder: (context, snapshot5) {
            if (snapshot5.hasData) {
              collection = snapshot5.data; //copy all the data into the list
              return connection == true
                  ? FutureBuilder<List>(
                      //if equal to true then continue retrieve other data
                      future: getStories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          bookData = snapshot.data;

                          bookDataR = [];
                          for (int i = 0; i < bookData.length; i++) {
                            if (bookData[i]['recommendation'] == 'Y') {
                              bookDataR.add(bookData[i]);
                            }
                          }

                          bookDataL = [];
                          for (int i = bookData.length - 1; i >= 0; i--) {
                            var parsedDate =
                                DateTime.parse(bookData[i]['dateOfCreation']);
                            var date =
                                DateTime.now().subtract(new Duration(days: 10));

                            if (date.isBefore(parsedDate)) {
                              //print(bookData[i]['dateOfCreation'].toString());
                              bookDataL.add(bookData[i]);
                            }
                          }
                          return new FutureBuilder<List>(
                              future: getReview(),
                              builder: (context, snapshot6) {
                                if (snapshot6.hasData) review = snapshot6.data;

                                return new FutureBuilder<List>(
                                  future: getWriter(),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      contributor = snapshot2.data;
                                      return new FutureBuilder<List>(
                                          future: db.getLanguage(widget
                                              .childrenID), //start by "db." means retrieve data from local database
                                          //retrieve children's selected languages from languagePreferred table
                                          builder: (context, snapshot3) {
                                            languageList = snapshot3.data;

                                            if (snapshot3.hasData) {
                                              bookList = [];
                                              for (int i = 0;
                                                  i < languageList.length;
                                                  i++) {
                                                //children selected languages.
                                                //filtering stories based on languages
                                                for (int j = 0;
                                                    j < bookData.length;
                                                    j++) {
                                                  //if match children's preferred languages

                                                  if (languageList[i]
                                                          .languageCode ==
                                                      bookData[j]
                                                          ['languageCode']) {
                                                    bookList.add(bookData[j]);
                                                  }
                                                }
                                              }
                                              bookList2 = [];
                                              for (int i = 0;
                                                  i < languageList.length;
                                                  i++) {
                                                //children selected languages.
                                                //filtering stories based on languages
                                                for (int j = 0;
                                                    j < bookDataR.length;
                                                    j++) {
                                                  //if match children's preferred languages

                                                  if (languageList[i]
                                                          .languageCode ==
                                                      bookDataR[j]
                                                          ['languageCode']) {
                                                    bookList2.add(bookDataR[j]);
                                                  }
                                                }
                                              }
                                              bookList3 = [];
                                              for (int i = 0;
                                                  i < languageList.length;
                                                  i++) {
                                                //children selected languages.
                                                //filtering stories based on languages
                                                for (int j = 0;
                                                    j < bookDataL.length;
                                                    j++) {
                                                  //if match children's preferred languages

                                                  if (languageList[i]
                                                          .languageCode ==
                                                      bookDataL[j]
                                                          ['languageCode']) {
                                                    bookList3.add(bookDataL[j]);
                                                  }
                                                }
                                              }

                                              return new FutureBuilder<List>(
                                                future: getLanguage(),
                                                builder: (context, snapshot4) {
                                                  if (snapshot4.hasData) {
                                                    languageData =
                                                        snapshot4.data;
                                                    return new Book_list(
                                                        bookData: bookList,
                                                        bookDataR: bookList2,
                                                        bookDataL: bookList3,
                                                        review: review,
                                                        contributor:
                                                            contributor,
                                                        childrenID:
                                                            widget.childrenID,
                                                        collection: collection,
                                                        languageData:
                                                            languageData,
                                                        page: widget.page,
                                                        bookData1: bookData1);
                                                  }
                                                  return SpinKitThreeBounce(
                                                      color: Colors.blue);
                                                },
                                              );
                                            }
                                            return SpinKitThreeBounce(
                                                color: Colors.blue);
                                          });
                                    }
                                    return SpinKitThreeBounce(
                                        color: Colors.blue);
                                  },
                                );
                              });
                        }
                        return SpinKitThreeBounce(color: Colors.blue);
                      },
                    )
                  : Book_list(
                      childrenID: widget.childrenID,
                      collection: collection,
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
  List bookData,
      bookDataR,
      contributor,
      collection,
      languageData,
      bookDataL,
      review;
  String childrenID;
  int page;
  Future<List> bookData1;

  @override
  Book_list(
      {Key key,
      this.childrenID,
      this.collection,
      this.page,
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

  String url = 'http://10.0.2.2/mmsr/';

  bool connection;
  void checkconnection() async {
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

  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createBookList();
    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            // refresh Button
            icon: const Icon(IconicIcons.loop),
            tooltip: 'Refresh',
            onPressed: () {
              setState(
                () {
                  checkconnection();
                  showInSnackBar();
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
          ),
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
          // BottomNavigationBarItem(
          //   icon: SizedBox(height:30, child:Image.asset('assets/img/stats.png')),
          //   title: Text('Stats'),
          // ),
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
              _buildCollection(context),
              _buildCollection(context),
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
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/img/error.png",
                  fit: BoxFit.cover,
                ),
                Text(
                  "No Internet Collection!",
                  style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
                ),
              ],
            ),
          )
        : widget.bookData.length == 0 // else if
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/img/sorry.png",
                      fit: BoxFit.cover,
                    ),
                    Text(
                      "Ops! No storybooks found.",
                      style:
                          TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientStart,
                          Colors.purple
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
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
                                              bookData: widget.bookData,
                                              contributor: widget.contributor,
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
                            widget.bookDataR.length != 0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Trending",
                                        style: TextStyle(
                                            letterSpacing: -1.5,
                                            fontFamily: 'SourceSansBold',
                                            color: const Color(0xffffffff),
                                            fontSize: 33),
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
                                                  builder: (context) => BookTab(
                                                        appBarTitle: "Trending",
                                                        review: widget.review,
                                                        bookData:
                                                            widget.bookData,
                                                        childrenID:
                                                            widget.childrenID,
                                                        bookDataRoL:
                                                            widget.bookDataR,
                                                        contributor:
                                                            widget.contributor,
                                                        languageData:
                                                            widget.languageData,
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
                                      viewportFraction: 0.9,
                                      scale: 0.5,
                                      itemCount: widget.bookDataR == null
                                          ? 0
                                          : widget.bookDataR.length,
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
                                        //To check who is the writer for the story.
                                        for (int j = 0;
                                            j < widget.contributor.length;
                                            j++) {
                                          if (widget.bookDataR[i]
                                                  ['ContributorID'] ==
                                              widget.contributor[j]
                                                  ['ContributorID']) {
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
                                          if (widget.review[j]['storybookID'] ==
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
                                                            bookData:
                                                                widget.bookData,
                                                            index: bookIndex,
                                                            contributor: name,
                                                            childrenID: widget
                                                                .childrenID,
                                                            language:
                                                                language)),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
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
                                                        image:
                                                            MemoryImage(bytes),
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
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    0.8),
                                                          ),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 40,
                                                                  right: 40),
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
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
                                                                  fontSize: 15,
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
                                                                        rating: double.parse(widget.bookDataR[i]['rating']) ==
                                                                                null
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
                                                                          TextOverflow
                                                                              .clip,
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
                                                                softWrap: false,
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
                            ?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "What's New",
                                  style: TextStyle(
                                      letterSpacing: -1.5,
                                      fontFamily: 'SourceSansBold',
                                      color: const Color(0xffffffff),
                                      fontSize: 30),
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
                                                  appBarTitle: "What's New",
                                                  bookData: widget.bookData,
                                                  review: widget.review,
                                                  childrenID: widget.childrenID,
                                                  bookDataRoL: widget.bookDataL,
                                                  contributor:
                                                      widget.contributor,
                                                  languageData:
                                                      widget.languageData,
                                                )),
                                      );
                                    }),
                              ],
                            )
                            : Container(),
                            widget.bookDataL.length != 0
                            ?
                            SizedBox(height: 10)
                            : Container(),
                            widget.bookDataL.length != 0
                            ?
                            Container(
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
                                    if (widget.bookDataL[i]['languageCode'] ==
                                        widget.languageData[j]
                                            ['languageCode']) {
                                      language = widget.languageData[j]
                                          ['languageDesc'];
                                    }
                                  }
                                  String name = '';
                                  //To check who is the writer for the story.
                                  for (int j = 0;
                                      j < widget.contributor.length;
                                      j++) {
                                    if (widget.bookDataL[i]['ContributorID'] ==
                                        widget.contributor[j]
                                            ['ContributorID']) {
                                      name = widget.contributor[j]['Name'];
                                    }
                                  }

                                  Uint8List bytes = base64Decode(
                                      widget.bookDataL[i]['storybookCover']);

                                  int bookIndex;
                                  for (int j = 0;
                                      j < widget.bookData.length;
                                      j++) {
                                    if (widget.bookData[j]['storybookID'] ==
                                            widget.bookDataL[i]
                                                ['storybookID'] &&
                                        widget.bookDataL[i]['languageCode'] ==
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
                                    if (widget.review[j]['storybookID'] ==
                                            widget.bookDataL[i]
                                                ['storybookID'] &&
                                        widget.review[j]['languageCode'] ==
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
                                                builder: (context) =>
                                                    LoadDetail(
                                                        bookData:
                                                            widget.bookData,
                                                        index: bookIndex,
                                                        contributor: name,
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
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(height: 3),
                                                    Container(
                                                      height: 42,
                                                      child: Text(
                                                        '${widget.bookDataL[i]['storybookTitle']}',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
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
                                                        fontFamily:
                                                            'SourceSansLight',
                                                        color: Colors.white,
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
                                                                  EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              1),
                                                              rating: double.parse(
                                                                          widget.bookData[i]
                                                                              [
                                                                              'rating']) ==
                                                                      null
                                                                  ? 0
                                                                  : double.parse(
                                                                      widget.bookDataL[
                                                                              i]
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
                            )
                            : Container(),
                            widget.bookDataL.length != 0
                            ?
                            SizedBox(height: 10)
                            : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "All Storybooks",
                                  style: TextStyle(
                                      letterSpacing: -1.5,
                                      fontFamily: 'SourceSansBold',
                                      color: const Color(0xffffffff),
                                      fontSize: 30),
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
                                                  appBarTitle: "All Storybooks",
                                                  bookData: widget.bookData,
                                                  review: widget.review,
                                                  childrenID: widget.childrenID,
                                                  bookDataRoL: widget.bookData,
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
                                  //To check who is the writer for the story.
                                  for (int j = 0;
                                      j < widget.contributor.length;
                                      j++) {
                                    if (widget.bookData[i]['ContributorID'] ==
                                        widget.contributor[j]
                                            ['ContributorID']) {
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
                                            widget.bookData[i]['storybookID'] &&
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
                                                        bookData:
                                                            widget.bookData,
                                                        index: i,
                                                        contributor: name,
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
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(height: 3),
                                                    Container(
                                                      height: 42,
                                                      child: Text(
                                                        '${widget.bookData[i]['storybookTitle']}',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
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
                                                                  EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              1),
                                                              rating: double.parse(
                                                                          widget.bookData[i]
                                                                              [
                                                                              'rating']) ==
                                                                      null
                                                                  ? 0
                                                                  : double.parse(
                                                                      widget.bookData[
                                                                              i]
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
    return storycollection.length == 0
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/img/empty.png",
                  fit: BoxFit.cover,
                ),
                Text(
                  "Empty! Download now at Gallery",
                  style: TextStyle(fontFamily: "WorkSansBold", fontSize: 20),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
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
                        GestureDetector(
                            onTap: ()

                                /* {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage(
                                          bookData: widget.bookData,
                                          contributor: widget.contributor,
                                          languageData: widget.languageData,
                                          childrenID: widget.childrenID,
                                        )),
                              );
                            }, */

                                {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchDownload(
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
                                for (int j = 0;
                                    j < languageAvailable.length;
                                    j++) {
                                  //languageAvailable has stored all the story id and languages.
                                  if (languageAvailable[j].story_id ==
                                      storycollection[i]
                                          .story_id) //to find out all available languages of the story.
                                  {
                                    //add language description into a list for display purpose.
                                    list.add(
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(8),
                                        color: Colors.black12,
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
                                Uint8List bytes = base64Decode(
                                    storycollection[i].story_cover);

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
                                                                  left: 12,
                                                                  right: 12),
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Wrap(
                                                                  alignment:
                                                                      WrapAlignment
                                                                          .start,
                                                                  children:
                                                                      list))),
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
                                                      LoadContent(
                                                        storyID:
                                                            storycollection[i]
                                                                .story_id,
                                                        childrenID:
                                                            widget.childrenID,
                                                        storyTitle:
                                                            storycollection[i]
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
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 30.0,
                                          child: PopupMenuButton<int>(
                                            onSelected: (value) {
                                              choiceAction(value, i);
                                            },
                                            icon: Icon(
                                              Icons.more_vert,
                                            ),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          'WorkSansBold'),
                                                ),
                                              ),
                                            ],
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

  void choiceAction(int choice, int i) async {
    var db = DBHelper();
    //delete all details of the storybook id
    if (choice == 1) {
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
}

class BookTab extends StatefulWidget {
  List bookData, bookDataRoL, contributor, languageData, review;
  String childrenID, appBarTitle;

  BookTab(
      {Key key,
      this.bookData,
      this.review,
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
                //To check who is the writer for the story.
                for (int j = 0; j < widget.contributor.length; j++) {
                  if (widget.bookDataRoL[i]['ContributorID'] ==
                      widget.contributor[j]['ContributorID']) {
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
                                  bookData: widget.bookData,
                                  index: bookIndex,
                                  contributor: name,
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
  List bookData, contributor, languageData;
  String childrenID;
  SearchPage(
      {Key key,
      this.bookData,
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
            widget.bookData[i]['dateOfCreation'],
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
            //To check who is the writer for the story.
            for (int j = 0; j < widget.contributor.length; j++) {
              if (story[index].contributor_id ==
                  widget.contributor[j]['ContributorID']) {
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
                          bookData: widget.bookData,
                          index: story[index].index,
                          contributor: name,
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
  SearchDownload(
      {Key key, this.storyData, this.languageAvailable, this.childrenID})
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
    print(widget.storyData[1].story_title);
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
            List<Widget> list = new List<Widget>();
            for (int j = 0; j < widget.languageAvailable.length; j++) {
              //languageAvailable has stored all the story id and languages.
              if (widget.languageAvailable[j].story_id ==
                  widget.storyData[index]
                      .story_id) //to find out all available languages of the story.
              {
                //add language description into a list for display purpose.
                list.add(
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(8),
                    color: Colors.black12,
                    child: Text(
                      widget.languageAvailable[j].languageDesc,
                      style: TextStyle(
                          fontSize: 14, fontFamily: 'SourceSansRegular'),
                    ),
                  ),
                );
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
