class Stats {
  String stats_id;
  String children_id;
  int num_read;
  int num_download;
  int num_login;
  
  Stats(
      this.stats_id,
      this.children_id,
      this.num_read,
      this.num_download,
      this.num_login);

  Stats.map(dynamic obj) {
    this.stats_id = obj['stats_id'];
    this.children_id = obj['children_id'];
    this.num_read = obj['num_read'];
    this.num_download = obj['num_download'];
    this.num_login = obj['num_login'];
  }
  String get _stats_id => stats_id;
  String get _children_id => children_id;
  int get _num_read => num_read;
  int get _num_download => num_download;
  int get _num_login => num_login;
  
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['stats_id'] = stats_id;
    map['children_id'] = children_id;
    map['num_read'] = num_read;
    map['num_download'] = num_download;
    map['num_login'] = num_login;
    return map;
  }
}
