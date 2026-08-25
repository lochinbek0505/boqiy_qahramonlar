class HashtegModel {
  num? id;
  String? hashteg;

  HashtegModel({
    this.id, this.hashteg
  });

  HashtegModel copyWith({
    num? id, String? hashteg
  }) => HashtegModel(id: id ?? this.id, hashteg: hashteg ?? this.hashteg);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["hashteg"] = hashteg;
    return map;
  }

  HashtegModel.fromJson(dynamic json) {
    id = json["id"];
    hashteg = json["hashteg"];
  }
}