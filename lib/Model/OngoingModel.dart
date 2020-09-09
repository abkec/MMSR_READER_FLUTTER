class OnGoing{
  String children_id;
  String story_id;
  int page_no;
  int duration;
  OnGoing(
      this.children_id ,
      this.story_id,
      this.page_no,
      this.duration,
      );

  OnGoing.map(dynamic obj){
    this.children_id = obj['children_id'];

    this.story_id = obj['story_id'];
    this.page_no = obj['page_no'];
    this.duration = obj['duration'];
  }
  String get _children_id => children_id;

  String get _story_id => story_id;
  int get _page_no => page_no;
  int get _duration => duration;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;

    map['story_id'] = story_id;
    map['page_no'] = page_no;
    map['duration'] = duration;
    return map;
  }
}
