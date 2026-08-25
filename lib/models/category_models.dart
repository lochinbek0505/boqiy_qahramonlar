class DataList {
  num? id;
  String? name;

  DataList({
    this.id, this.name
  });

  DataList copyWith({
    num? id, String? name
  }) => DataList(id: id ?? this.id, name: name ?? this.name);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  DataList.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
  }
}

class CategoryModels {
  List<DataList>? dataListList;

  CategoryModels({
    this.dataListList
  });

  CategoryModels copyWith({
    List<DataList>? dataListList
  }) => CategoryModels(dataListList: dataListList ?? this.dataListList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  CategoryModels.fromJson(dynamic json) {
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}