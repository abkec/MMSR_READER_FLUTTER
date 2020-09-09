class History{
  String children_id;
  String story_title;
  int duration;
  String read_date;

  History(this.children_id,this.story_title,
      this.duration,this.read_date);

  History.map(dynamic obj){
    this.children_id = obj['children_id'];
    this.story_title = obj['story_title'];
    this.duration = obj['duration'];
    this.read_date = obj['read_date'];
  }

  String get _children_id => children_id;
  String get _story_title => story_title;
  int get _duration => duration;
  String get _read_date => read_date;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;
    map['story_title'] = story_title;
    map['duration'] = duration;
    map['read_date'] = read_date;
    return map;
  }
}
