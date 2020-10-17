import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reader_mmsr/Model/ChildrenModel.dart';
import 'package:reader_mmsr/Model/HistoryModel.dart';
import 'package:reader_mmsr/Model/OngoingModel.dart';
import 'package:reader_mmsr/Model/PageImageModel.dart';
import 'package:reader_mmsr/Model/PageTextModel.dart';
import 'package:reader_mmsr/Model/StatsModel.dart';
import 'package:reader_mmsr/Model/StoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:path/path.dart';
import 'package:reader_mmsr/Model/ParentModel.dart';
import 'package:reader_mmsr/Model/LanguagePreferredModel.dart';

class DBHelper{
  static final DBHelper _instance = new DBHelper.internal();
  DBHelper.internal();

  factory DBHelper() => _instance;

  static Database _db;

  Future<Database> get db async{
    if(_db!=null) return _db;
    _db = await setDB();
    return _db;
  }

  setDB()async{
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,"ReaderDB");
    var db = await openDatabase(path,version: 1,onCreate:  _onCreate);
    return db;
  }
  void _onCreate(Database db, int version)async{
    //children table
    await db.execute("CREATE TABLE Children("
        "children_id TEXT PRIMARY KEY,"
        "parent_username TEXT,"
        "children_name TEXT,"
        "children_DOB DATE,"
        "children_gender TEXT,"
        "children_image TEXT);");
    print('children table created');
    //parent table
    await db.execute("CREATE TABLE Parent("
        "username TEXT PRIMARY KEY,"
        "password TEXT,"
        "parent_name TEXT,"
        "parent_email TEXT,"
        "parent_gender TEXT,"
        "parent_DOB DATE);");
    print('parent table created');

    //story collection table
    await db.execute("CREATE TABLE StoryCollection("
        "story_id TEXT,"
        "children_id TEXT,"
        "story_name TEXT,"
        "story_cover BLOB,"
        "story_title TEXT,"
        "download_date DATE,"
        "contributor_name TEXT,"
        "languageCode TEXT,"
        "languageDesc TEXT,"
        "PRIMARY KEY (story_id,children_id,languageCode));");
    print('story collection table created');

    //page content image table
    await db.execute("CREATE TABLE PageImage("
        "story_id TEXT,"
        "children_id TEXT,"
        "story_image BLOB,"
        "page_no INTEGER,"
        "PRIMARY KEY (story_id, page_no,children_id));");
    print('page image table created');

    //page content text table
    await db.execute("CREATE TABLE PageText("
        "children_id TEXT,"
        "story_id TEXT,"
        "story_content TEXT,"
        "languageCode TEXT,"
        "languageDesc TEXT," //EN,ZH,MS
        "page_no INTEGER,"
        "speech_id TEXT,"
        "story_image BLOB,"
        "PRIMARY KEY (story_id, languageCode,children_id,page_no));");
    print('page text table created');

    //reading history table
    await db.execute("CREATE TABLE History("
        "history_id TEXT PRIMARY KEY,"
        "children_id TEXT ,"
        "story_title TEXT,"
        "duration INTEGER,"
        "read_date DATE);");
    print('history table created');

    //LanguagePreferred table
    await db.execute("CREATE TABLE LanguagePreferred("
        "children_id TEXT,"
        "languageCode TEXT,"
        "PRIMARY KEY ( children_id, languageCode)"
        ");");
    print('languagepreferred table created');

    //stats table
    await db.execute("CREATE TABLE Stats("
        "stats_id TEXT PRIMARY KEY,"
        "children_id TEXT ,"
        "num_read INTEGER,"
        "num_download INTEGER,"
        "num_login INTEGER);");
    print('stats table created');

    //SpeechLanguage table
//    await db.execute("CREATE TABLE SpeechLanguage("
//        "speech_id TEXT,"
//        "languageCode TEXT,"
//        "PRIMARY KEY ( speech_id, languageCode)"
//        ");");
//    print('SpeechLanguage table created');

    //Ongoing table
    await db.execute("CREATE TABLE Ongoing("
        "children_id TEXT,"
        "story_id TEXT,"
        "page_no INTEGER,"
        "duration INTEGER,"
        "PRIMARY KEY (story_id, children_id)"
        ");");
    print('Ongoing table created');
    print("DB Created");
  }
  //Parent
  ////////////////////////////////////////////////////////////////////////
  Future<int> saveParent(Parent parent) async{
    var dbClient = await db;
    int res = await dbClient.insert("Parent", parent.toMap());
    return res;
  }

  Future<List<Parent>> getParent() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Parent WHERE username = '$loginID'");
    List<Parent> parentData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new Parent(list[i]['username'], list[i]['password'], list[i]['parent_name'],
          list[i]['parent_email'], list[i]['parent_gender'],list[i]['parent_DOB']);
      parentData.add(data);
    }
    return parentData;
  }
  Future<bool> updateParent(Parent parent)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    var dbClient = await db;
    int res = await dbClient.update("Parent", parent.toMap(), where: "username=?",
        whereArgs: <String>[loginID]);
    return res>0? true:false;
  }
  Future<bool> updateUsername(Children children)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    var dbClient = await db;
    int res = await dbClient.update("Children", children.toMap(), where: "parent_username=?",
        whereArgs: <String>[loginID]);
    return res>0? true:false;
  }

  ///////////////////////////////////////////////////

  //Children
//////////////////////////////////////////////////////////////////
  Future<int> saveChildren(Children children) async{

    var dbClient = await db;
    int res = await dbClient.insert("Children", children.toMap());
    return res;
  }

  Future<List<Children>> getChildren() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginID = prefs.getString('loginID');
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Children WHERE parent_username = '$loginID'");
    List<Children> childrenData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new Children(list[i]['children_id'], list[i]['parent_username'],
          list[i]['children_name'],
          list[i]['children_DOB'], list[i]['children_gender'],list[i]['children_image']);
      childrenData.add(data);
    }
    return childrenData;
  }
  Future<List<Children>> getChildrenByID(String id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Children WHERE children_id = '$id'");
    List<Children> childrenData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new Children(list[i]['children_id'], list[i]['parent_username'],
          list[i]['children_name'],
          list[i]['children_DOB'], list[i]['children_gender'],list[i]['children_image']);
      childrenData.add(data);
    }
    return childrenData;
  }
  Future<int> deleteChildren(String id)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM Children WHERE children_id='$id'");
    return res;
  }
//test
  Future<int> deleteParent(String id)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM Parent WHERE username='$id'");
    return res;
  }

  //test 
  Future<bool> updateChildren(Children children)async{
    var dbClient = await db;
    int res = await dbClient.update("Children", children.toMap(), where: "children_id=?",
    whereArgs: <String>[children.children_id]);
    return res>0? true:false;
  }
//////////////////////////////////////////////////////////////////

//language Preferred
///////////////////////////////////////////////////////////////////////////////
  Future<int> saveLanguagePreferred(LanguagePreferred languagePreferred) async{
    var dbClient = await db;
    int res = await dbClient.insert("LanguagePreferred", languagePreferred.toMap());
    print(languagePreferred.toMap());
    return res;
  }

  Future<int> deleteLanguagePreferred(String id)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM LanguagePreferred WHERE children_id=?",[id]);
    return res;
  }
  Future<List<LanguagePreferred>> getLanguage(String id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM LanguagePreferred WHERE children_id = '$id'");
    List<LanguagePreferred> languageData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new LanguagePreferred(list[i]['children_id'], list[i]['languageCode'],);
      languageData.add(data);
    }
    return languageData;
  }

///////////////////////////////////////////////////////////////////////////////

  //StorybookCollection
///////////////////////////////////////////////////////////////////////////////
  Future<int> downloadBook(StoryCollection storyCollection) async{
    var dbClient = await db;
    int res = await dbClient.insert("StoryCollection", storyCollection.toMap());
    return res;
  }

  Future<int> deleteBook(String id,String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM StoryCollection WHERE story_id=? and children_id =?",[id,children]);
    return res;
  }
  Future<int> deleteAllBook(String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM StoryCollection WHERE children_id =?",[children]);
    return res;
  }
  Future<List<StoryCollection>> getStories(String id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM StoryCollection WHERE children_id = '$id' ORDER BY story_id");
    List<StoryCollection> storyData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new StoryCollection(list[i]['story_id'], list[i]['children_id'],
          list[i]['story_cover'],list[i]['story_title'], list[i]['download_date'],list[i]['contributor_name'],list[i]['languageCode'],list[i]['languageDesc']);
      storyData.add(data);
    }
    return storyData;
  }
///////////////////////////////////////////////////////////////////////////////

 //Stats
///////////////////////////////////////////////////////////////////////////////
  Future<int> saveStats(String children_id) async{
    var dbClient = await db;
    //get the biggest id in the table
    var table = await dbClient.rawQuery("SELECT stats_id as id FROM Stats");
    int id = table.length+1;
    if (id == null)
      {
        id = 0;
      }
    //insert to the table using the new id
    var raw = await dbClient.rawInsert(
        "INSERT Into Stats (stats_id,children_id,num_read,num_download,num_login)"
            " VALUES (?,?,?,?,?)",
        [id, children_id, 0, 0, 0]);
    return raw;
  }

  Future<int> deleteStats(String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM Stats WHERE children_id =?",[children]);
    return res;
  }
  
  Future<List<Stats>> getStats(String id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Stats WHERE children_id = '$id'");
    List<Stats> statsData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new Stats(list[i]['stats_id'], list[i]['children_id'],
          list[i]['num_read'],list[i]['num_download'], list[i]['num_login']);
      statsData.add(data);
    }
    return statsData;
  }
///////////////////////////////////////////////////////////////////////////////
  //PageContent
///////////////////////////////////////////////////////////////////////////////
  Future<int> downloadText(PageTextModel pageTextModel) async{
    var dbClient = await db;
    int res = await dbClient.insert("PageText", pageTextModel.toMap());
    return res;
  }

  Future<int> deleteText(String id,String children, String language)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM PageText WHERE story_id=? and children_id = ? and languageCode = ?",[id,children,language]);
    return res;
  }
  Future<int> deleteAllText(String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM PageText WHERE children_id = ?",[children]);
    return res;
  }
  Future<List<PageTextModel>> getText(String id,String childrenID) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM PageText WHERE story_id = '$id' AND children_id ='$childrenID' ORDER BY page_no");
    List<PageTextModel> textData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new PageTextModel(list[i]['children_id'],list[i]['story_id'], list[i]['story_content'],list[i]['languageCode'],list[i]['languageDesc'],
          list[i]['page_no'],list[i]['speech_id'],list[i]['story_image']);
      textData.add(data);
    }
    return textData;
  }
  Future<List<PageTextModel>> getTextDistinct(String id,String children) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT DISTINCT languageCode,languageDesc FROM PageText WHERE story_id = '$id' and children_id ='$children'");
    List<PageTextModel> textData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new PageTextModel(list[i]['children_id'],list[i]['story_id'], list[i]['story_content'],list[i]['languageCode'],
          list[i]['languageDesc'],list[i]['page_no'],list[i]['speech_id'],list[i]['story_image']);
      textData.add(data);
    }
    return textData;
  }
///////////////////////////////////////////////////////////////////////////////

  //Ongoing
  ////////////////////////////////////////////////////////////////////////
  Future<int> saveOngoing(OnGoing onGoing) async{
    var dbClient = await db;
    int res = await dbClient.insert("Ongoing", onGoing.toMap());
    return res;
  }

  Future<List<OnGoing>> getOngoing(String children_id, String story_id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Ongoing WHERE children_id ='$children_id' AND story_id = '$story_id'");
    List<OnGoing> ongoingData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new OnGoing(list[i]['children_id'], list[i]['story_id'], list[i]['page_no'],
          list[i]['duration']);
      ongoingData.add(data);
    }

    return ongoingData;
  }
  Future<bool> updateOngoing(OnGoing onGoing)async{
    var dbClient = await db;
    int res = await dbClient.update("OnGoing", onGoing.toMap(), where: "children_id=? AND story_id = ?",
        whereArgs: <String>[onGoing.children_id,onGoing.story_id]);
    if(res != 1) {
      saveOngoing(onGoing);
    }
    return res>0? true:false;

  }
  Future<int> deleteOngoing(String story_id,String children_id)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM OnGoing WHERE story_id=? and children_id =? ",[story_id,children_id]);
    return res;
  }

  Future<int> deleteAllOngoing(String children_id)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM OnGoing WHERE children_id =? ",[children_id]);
    return res;
  }
///////////////////////////////////////////////////


  //History
  ////////////////////////////////////////////////////////////////////////
  Future<int> saveHistory(History history) async{
    var dbClient = await db;
    //get the biggest id in the table
    var table = await dbClient.rawQuery("SELECT history_id as id FROM History");
    int id = table.length+1;
    if (id == null)
      {
        id = 0;
      }
    //insert to the table using the new id
    var raw = await dbClient.rawInsert(
        "INSERT Into History (history_id,children_id,story_title,duration,read_date)"
            " VALUES (?,?,?,?,?)",
        [id, history.children_id, history.story_title, history.duration,history.read_date]);
    return raw;
  }

  Future<List<History>> getHistory(String children_id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM History  WHERE children_id ='$children_id'");
    List<History> ongoingData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new History(list[i]['children_id'], list[i]['story_title'],
          list[i]['duration'],list[i]['read_date']);
      ongoingData.add(data);
    }

    return ongoingData;
  }
  Future<List<History>> getHistoryDistinct(String children_id) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT DISTINCT read_date FROM History WHERE children_id ='$children_id' "
        "ORDER BY read_date DESC");
    List<History> ongoingData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new History(list[i]['children_id'], list[i]['story_title'],
          list[i]['duration'],list[i]['read_date']);
      ongoingData.add(data);
    }
    return ongoingData;
  }

//pageImage
  Future<int> downloadImage(PageImageModel pageTextModel) async{
    var dbClient = await db;
    int res = await dbClient.insert("PageImage", pageTextModel.toMap());
    return res;
  }

  Future<int> deleteImage(String id,String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM PageImage WHERE story_id=? and children_id = ?",[id,children]);
    return res;
  }
  Future<int> deleteAllImage(String children)async{
    var dbClient = await db;
    int res = await dbClient.rawDelete("DELETE FROM PageImage WHERE children_id = ?",[children]);

    return res;
  }
  Future<List<PageImageModel>> getImage(String id,String childrenID) async{
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM PageImage WHERE story_id = '$id' AND children_id ='$childrenID' ORDER BY page_no");
    List<PageImageModel> imageData = new List();
    for(int i = 0; i<list.length;i++)
    {
      var data = new PageImageModel(list[i]['children_id'],list[i]['story_id'], list[i]['story_image'],
          list[i]['page_no']);
      imageData.add(data);
    }
    return imageData;
  }

}