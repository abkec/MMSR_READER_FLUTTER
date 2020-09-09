class Children{
  String children_id;
  String parent_username;
  String children_name;
  String children_DOB;
  String children_gender;
  String children_image;

  Children(this.children_id,this.parent_username,this.children_name,
      this.children_DOB,this.children_gender,this.children_image);



  String get _children_id => children_id;
  String get _parent_username => parent_username;
  String get _children_name => children_name;
  String get _children_DOB => children_DOB;
  String get _children_gender => children_gender;
  String get _children_image => children_image;

  Children.map(dynamic obj){
    this.children_id = obj['children_id'];
    this.parent_username = obj['parent_username'];
    this.children_name = obj['children_name'];
    this.children_DOB = obj['children_DOB'];
    this.children_gender = obj['children_gender'];
    this.children_image = obj['children_image'];
  }
  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['children_id'] = children_id;
    map['parent_username'] = parent_username;
    map['children_name'] = children_name;
    map['children_DOB'] = children_DOB;
    map['children_gender'] = children_gender;
    map['children_image'] = children_image;
    return map;
  }
}
