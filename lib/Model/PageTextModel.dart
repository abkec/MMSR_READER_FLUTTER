class PageTextModel{
  String children_id;
  String story_id;
  String story_content;
  String languageCode;
  String languageDesc;
  int page_no;
  String speech_id;
  String story_image;

  PageTextModel(
      this.children_id,
      this.story_id,
      this.story_content ,
      this.languageCode,
      this.languageDesc,
      this.page_no,
      this.speech_id,
      this.story_image
      );

  PageTextModel.map(dynamic obj){
    this.children_id = obj['children_id'];

    this.story_id = obj['story_id'];
    this.story_content = obj['story_content'];
    this.languageCode = obj['languageCode'];
    this.languageDesc = obj['languageDesc'];
    this.page_no = obj['page_no'];
    this.speech_id=obj['speech_id'];
    this.story_image=obj['story_image'];
  }
  String get _story_id => story_id;
  String get _story_content => story_content;
  String get _languageCode => languageCode;
  String get _languageDesc => languageDesc;
  int get _page_no => page_no;
  String get _speech_id=> speech_id;
  String get _children_id=>children_id;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;
    map['story_id'] = story_id;
    map['story_content'] = story_content;
    map['languageCode'] = languageCode;
    map['languageDesc'] = languageDesc;
    map['page_no'] = page_no;
    map['speech_id'] = speech_id;
    map['story_image'] = story_image;
    return map;
  }
}
