class Bookmark {
  final int page;

  Bookmark(this.page);

  Map<String, dynamic> toJson() => {"page": page};

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(json["page"]);
  }
}