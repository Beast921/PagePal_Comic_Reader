class Tile{
  String url, coverUrl, title;
  int? id;

  Tile(this.coverUrl, this.url, this.title, {this.id});

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      json['cover'] as String,
      json['link'] as String,
      json['title'] as String,
    );
  }
}