class Stats {
  String stats_id;
  String children_id;
  int num_read;
  int num_download;
  int num_rate;
  int num_follow;
  
  Stats(
      this.stats_id,
      this.children_id,
      this.num_read,
      this.num_download,
      this.num_rate,
      this.num_follow);

  Stats.map(dynamic obj) {
    this.stats_id = obj['stats_id'];
    this.children_id = obj['children_id'];
    this.num_read = obj['num_read'];
    this.num_download = obj['num_download'];
    this.num_rate = obj['num_rate'];
    this.num_follow = obj['num_follow'];
  }
  String get _stats_id => stats_id;
  String get _children_id => children_id;
  int get _num_read => num_read;
  int get _num_download => num_download;
  int get _num_rate => num_rate;
  int get _num_follow => num_follow;
  
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['stats_id'] = stats_id;
    map['children_id'] = children_id;
    map['num_read'] = num_read;
    map['num_download'] = num_download;
    map['num_rate'] = num_rate;
    map['num_follow'] = num_follow;
    return map;
  }
}
