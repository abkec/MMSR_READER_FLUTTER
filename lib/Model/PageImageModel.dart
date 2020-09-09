class PageImageModel{
  String children_id;
  String story_id;
  String story_image;
  int page_no;

  PageImageModel(
      this.children_id,
      this.story_id,
      this.story_image ,
      this.page_no,
      );

  PageImageModel.map(dynamic obj){
    this.children_id = obj['children_id'];

    this.story_id = obj['story_id'];
    this.story_image = obj['story_image'];
    this.page_no = obj['page_no'];
  }
  String get _story_id => story_id;
  String get _story_image => story_image;
  int get _page_no => page_no;
  String get _children_id=>children_id;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;
    map['story_id'] = story_id;
    map['story_image'] = story_image;
    map['page_no'] = page_no;
    return map;
  }
}
