class LanguagePreferred{
  String children_id;
  String languageCode;


  LanguagePreferred(this.children_id,this.languageCode);

  LanguagePreferred.map(dynamic obj){
    this.children_id = obj['children_id'];
    this.languageCode = obj['languageCode'];

  }

  String get _children_id => children_id;
  String get _languageCode=> languageCode;


  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;
    map['languageCode'] = languageCode;
    return map;
  }
}
