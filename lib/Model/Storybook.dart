class Storybook {
  String story_id;
  String story_title;
  String story_cover;
  String story_desc;
  String story_genre;
  String story_date;
  String status;
  String contributor_id;
  String languageCode;
  int index;
  // String reviewer;
  // String comments;

  Storybook(
      this.story_id,
      this.story_title,
      this.story_cover,
      this.story_desc,
      this.story_genre,
      this.story_date,
      this.status,
      this.contributor_id,
      this.languageCode,
      this.index);

  Storybook.map(dynamic obj) {
    this.story_id = obj['story_id'];
    this.story_title = obj['story_title'];
    this.story_cover = obj['story_cover'];
    this.story_desc = obj['story_desc'];
    this.story_genre = obj['story_genre'];
    this.story_date = obj['story_date'];
    this.status = obj['status'];
    this.contributor_id = obj['contributor_id'];
    this.languageCode = obj['languageCode'];
    this.index = obj['index'];
  }
  String get _story_id => story_id;
  String get _story_title => story_title;
  String get _story_cover => story_cover;
  String get _story_desc => story_desc;
  String get _story_genre => story_genre;
  String get _story_date => story_date;
  String get _status => status;
  String get _contributor_id => contributor_id;
  String get _languageCode => languageCode;
  int get _index => index;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['story_id'] = story_id;
    map['story_title'] = story_title;
    map['story_cover'] = story_cover;
    map['story_desc'] = story_desc;
    map['story_genre'] = story_genre;
    map['story_date'] = story_date;
    map['status'] = status;
    map['contributor_id'] = contributor_id;
    map['languageCode'] = languageCode;
     map['index'] = index;
    return map;
  }
}
