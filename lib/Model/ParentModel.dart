class Parent{
  String username;
  String password;
  String parent_name;
  String parent_gender;
  String parent_email;
  String parent_DOB;

  Parent(this.username,this.password,this.parent_gender,this.parent_email,this.parent_name,this.parent_DOB);

  Parent.map(dynamic obj){
    this.username = obj['username'];
    this.password = obj['password'];
    this.parent_name = obj['parent_name'];
    this.parent_email = obj['parent_email'];
    this.parent_gender = obj['parent_gender'];
    this.parent_DOB = obj['parent_DOB'];
  }

  String get _username => username;
  String get _password => password;
  String get _parent_name => parent_name;
  String get _parent_email => parent_email;
  String get _parent_gender => parent_gender;
  String get _parent_DOB => parent_DOB;

  Map<String,dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['username'] = username;
    map['password'] = password;
    map['parent_name'] = parent_name;
    map['parent_email'] = parent_email;
    map['parent_gender'] = parent_gender;
    map['parent_DOB'] = parent_DOB;
    return map;
  }
}
