class Chapter{
  int read, chapterNumber, download, sourceOrder;
  int? lastRead, chapterId, mangaId;
  String url, name;
  String? scanlator, uploadDate;

  Chapter(this.name, this.url, this.sourceOrder, this.chapterNumber, {this.chapterId, this.mangaId, this.uploadDate, this.read=0, this.download=0});
}