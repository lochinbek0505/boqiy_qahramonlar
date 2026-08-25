class Author {
  num? id;
  String? username;
  String? password;
  String? profileImageUrl;
  String? name;
  String? role;

  Author({
    this.id, this.username, this.password, this.profileImageUrl, this.name, this.role
  });

  Author copyWith({
    num? id, String? username, String? password, String? profileImageUrl, String? name, String? role
  }) =>
      Author(id: id ?? this.id,
          username: username ?? this.username,
          password: password ?? this.password,
          profileImageUrl: profileImageUrl ?? this.profileImageUrl,
          name: name ?? this.name,
          role: role ?? this.role);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["username"] = username;
    map["password"] = password;
    map["profileImageUrl"] = profileImageUrl;
    map["name"] = name;
    map["role"] = role;
    return map;
  }

  Author.fromJson(dynamic json) {
    id = json["id"];
    username = json["username"];
    password = json["password"];
    profileImageUrl = json["profileImageUrl"];
    name = json["name"];
    role = json["role"];
  }
}

class HashTeg {
  num? id;
  String? hashteg;

  HashTeg({
    this.id, this.hashteg
  });

  HashTeg copyWith({
    num? id, String? hashteg
  }) => HashTeg(id: id ?? this.id, hashteg: hashteg ?? this.hashteg);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["hashteg"] = hashteg;
    return map;
  }

  HashTeg.fromJson(dynamic json) {
    id = json["id"];
    hashteg = json["hashteg"];
  }
}

class HistoryModel {
  num? id;
  String? title;
  String? liveDate;
  String? bannerUrl;
  String? content;
  num? viewCount;
  num? readTime;
  Author? author;
  List<HashTeg>? hashTegsList;
  String? createAt;
  String? updatedAt;

  HistoryModel({
    this.id, this.title, this.liveDate, this.bannerUrl, this.content, this.viewCount, this.readTime, this.author, this.hashTegsList, this.createAt, this.updatedAt
  });

  HistoryModel copyWith({
    num? id, String? title, String? liveDate, String? bannerUrl, String? content, num? viewCount, num? readTime, Author? author, List<
        HashTeg>? hashTegsList, String? createAt, String? updatedAt
  }) =>
      HistoryModel(id: id ?? this.id,
          title: title ?? this.title,
          liveDate: liveDate ?? this.liveDate,
          bannerUrl: bannerUrl ?? this.bannerUrl,
          content: content ?? this.content,
          viewCount: viewCount ?? this.viewCount,
          readTime: readTime ?? this.readTime,
          author: author ?? this.author,
          hashTegsList: hashTegsList ?? this.hashTegsList,
          createAt: createAt ?? this.createAt,
          updatedAt: updatedAt ?? this.updatedAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["title"] = title;
    map["liveDate"] = liveDate;
    map["bannerUrl"] = bannerUrl;
    map["content"] = content;
    map["view_count"] = viewCount;
    map["read_time"] = readTime;
    if (author != null) {
      map["author"] = author?.toJson();
    }
    if (hashTegsList != null) {
      map["hashTegs"] = hashTegsList?.map((v) => v.toJson()).toList();
    }
    map["createAt"] = createAt;
    map["updatedAt"] = updatedAt;
    return map;
  }

  HistoryModel.fromJson(dynamic json) {
    id = json["id"];
    title = json["title"];
    liveDate = json["liveDate"];
    bannerUrl = json["bannerUrl"];
    content = json["content"];
    viewCount = json["view_count"];
    readTime = json["read_time"];
    author = json["author"] != null ? Author.fromJson(json["author"]) : null;
    if (json["hashTegs"] != null) {
      hashTegsList = [];
      json["hashTegs"].forEach((v) {
        hashTegsList?.add(HashTeg.fromJson(v));
      });
    }
    createAt = json["createAt"];
    updatedAt = json["updatedAt"];
  }
}