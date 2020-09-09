class StoryCollection{
  String story_id;
  String children_id;
  String story_cover;
  String story_title;
  String download_date;
  String contributor_name;
  String languageCode;
  String languageDesc;

  StoryCollection(
      this.story_id,
      this.children_id ,
      this.story_cover,
      this.story_title,
      this.download_date,
      this.contributor_name,
      this.languageCode,
      this.languageDesc
  );

  StoryCollection.map(dynamic obj){
    this.story_id = obj['story_id'];
    this.children_id = obj['children_id'];
    this.story_cover = obj['story_cover'];
    this.story_title = obj['story_title'];
    this.download_date = obj['download_date'];
    this.contributor_name = obj['contributor_name'];
    this.languageCode = obj['languageCode'];
    this.languageDesc = obj['languageDesc'];
  }
  String get _story_id => story_id;
  String get _children_id => children_id;
  String get _story_cover => story_cover;
  String get _story_title => story_title;
  String get _download_date => download_date;
  String get _contributor_name=>contributor_name;
  String get _languageCode=>languageCode;
  String get _languageDesc=>languageDesc;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['story_id'] = story_id;
    map['children_id'] = children_id;
    map['story_cover'] = story_cover;
    map['story_title'] = story_title;
    map['download_date'] = download_date;
    map['contributor_name']=contributor_name;
    map['languageCode']=languageCode;
    map['languageDesc']=languageDesc;
    return map;
  }
}
