class CategoryModel {
  num? id;
  String? name;

  CategoryModel({
    this.id, this.name
  });

  CategoryModel copyWith({
    num? id, String? name
  }) => CategoryModel(id: id ?? this.id, name: name ?? this.name);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  CategoryModel.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
  }
}