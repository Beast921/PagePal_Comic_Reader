class Manga {
  int favourite,
      initialized,
      viewer, download;
  int? mangaId, chapterFlags;
  String source, url, title, status, thumbnailUrl;
  String? description;
  List<String> genres, author;
  List<String>? artist;

  Manga(this.title, this.source, this.url, this.thumbnailUrl,
      this.status, this.description, this.author, this.genres,
      {this.artist, this.mangaId, this.favourite = 0, this.initialized = 0, this.viewer = 0, this.download=0});
}