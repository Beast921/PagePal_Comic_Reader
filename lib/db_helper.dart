import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test_shit/chapter.dart';
import 'package:test_shit/tile.dart';
import 'manga.dart';

class DatabaseHelper {
  static const _databaseName = "pagepal.db";
  static const _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // open the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE manga (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            source TEXT NOT NULL,
            url TEXT NOT NULL,
            favourite INTEGER NOT NULL,
            artist TEXT,
            author TEXT,
            description TEXT,
            thumbnail_url TEXT,
            status TEXT,
            genres TEXT,
            initialized INTEGER,
            chapter_flags INTEGER,
            download INTEGER,
            viewer INTEGER
          )
          ''');

    await db.execute('''
            CREATE TABLE chapter (
              id INTEGER PRIMARY KEY,
              manga_id INTEGER NOT NULL,
              url TEXT NOT NULL,
              name TEXT NOT NULL,
              chapter_number INTEGER NOT NULL,
              source_order INTEGER NOT NULL,
              date_upload TEXT,
              scanlator TEXT,
              read INTEGER,
              last_page_read INTEGER,
              download INTEGER,
              FOREIGN KEY(manga_id) REFERENCES manga(id)
             )
             ''');
  }

  Future<int> insertManga(Manga m) async {
    final db = await database;
    String artist = '', author = '', genres = '';
    for(var a in m.artist!){
      artist += '$a,';
    }
    for(var a in m.author!){
      author += '$a,';
    }
    for(var a in m.genres!){
      genres += '$a,';
    }
    Map<String, dynamic> values = {
      'title': m.title,
      'source': m.source,
      'url': m.url,
      'favourite': m.favourite,
      'artist': artist,
      'author': author,
      'description': m.description,
      'thumbnail_url': m.thumbnailUrl,
      'status': m.status,
      'genres': genres,
      'initialized': m.initialized,
      'chapter_flags': m.chapterFlags,
      'download': m.download,
      'viewer': m.viewer
    };
    return await db.insert('manga', values);
  }

  Future insertChapter(Chapter c) async {
    final db = await database;
    Map<String, dynamic> values = {
      'manga_id': c.mangaId,
      'url': c.url,
      'name': c.name,
      'chapter_number': c.chapterNumber,
      'source_order': c.sourceOrder,
      'date_upload': c.uploadDate,
      'scanlator': c.scanlator,
      'read': c.read,
      'last_page_read': c.lastRead,
      'download': c.download
    };
    return await db.insert('chapter', values);
  }

  Future<void> deleteManga(int id) async {
    final db = await database;
    await db.delete(
      'manga',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteChapters(int id) async {
    final db = await database;
    await db.delete(
      'chapter',
      where: 'manga_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFavouriteMangas() async {
    final db = await database;
    return await db.query('manga',
        columns: ['title', 'url', 'thumbnail_url', 'id'],
        where: 'favourite = ?',
        whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> getManga(int id) async {
    final db = await database;
    return await db.query('manga',
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMangaByUrl(String url) async {
    final db = await database;
    return await db.query('manga',
        where: 'url = ?',
        whereArgs: [url]);
  }

  Future<List<Map<String, dynamic>>> getChapter(int id) async {
    final db = await database;
    return await db.query('chapter',
        where: 'manga_id = ?',
        whereArgs: [id]);
  }
}

class DBStuff {
  Future<Manga> addFavourite(Manga m, List<Chapter> chaps) async {
    DatabaseHelper d = DatabaseHelper.instance;
    int? id = await d.insertManga(m);
    m.mangaId = id;
    for(Chapter c in chaps){
      c.mangaId = id;
      await d.insertChapter(c);
    }
    m.favourite = 1;
    return m;
  }

  Future<Manga?> removeFavorite(Manga? m) async {
    DatabaseHelper d = DatabaseHelper.instance;
    if(m != null){
      await d.deleteChapters(m.mangaId ?? -1);
      await d.deleteManga(m.mangaId ?? -1);
    }
    m?.mangaId = null;
    m?.favourite = 0;
    return m;
  }

  Future<List<Tile>> getFavouriteMangas() async {
    DatabaseHelper d = DatabaseHelper.instance;
    List<Map<String, dynamic>> res = await d.getFavouriteMangas();
    List<Tile> mangas = [];
    for(var r in res){
      Tile t = Tile(r['thumbnail_url'], r['url'], r['title'], id: r['id']);
      mangas.add(t);
    }
    return mangas;
  }

  Future<Manga?> getDetails(int id) async {
    DatabaseHelper d = DatabaseHelper.instance;
    List<Map<String, dynamic>> res = await d.getManga(id);
    Manga? m;
    for(var r in res){
      List<String> author = [], genres = [];
      author = r['author'].split(',');
      genres = r['genres'].split(',');
      List<String>? artist =r['artist'].split(',');
      m = Manga(r['title'], r['source'], r['url'], r['thumbnail_url'], r['status'], r['description'], author, genres, artist: artist, favourite: r['favourite'], mangaId: r['id'], initialized: r['initialized'], viewer: r['viewer'], download: r['download']);
    }
    return m;
  }

  Future<Manga?> getDetailsByUrl(String url) async {
    DatabaseHelper d = DatabaseHelper.instance;
    List<Map<String, dynamic>> res = await d.getMangaByUrl(url);
    Manga? m;
    for(var r in res){
      List<String> author = [], genres = [];
      author = r['author'].split(',');
      genres = r['genres'].split(',');
      List<String>? artist =r['artist'].split(',');
      m = Manga(r['title'], r['source'], r['url'], r['thumbnail_url'], r['status'], r['description'], author, genres, artist: artist, favourite: r['favourite'], mangaId: r['id'], initialized: r['initialized'], viewer: r['viewer'], download: r['download']);
    }
    return m;
  }

  Future<List<Chapter>> getChapters(int id) async {
    DatabaseHelper d = DatabaseHelper.instance;
    List<Map<String, dynamic>> res = await d.getChapter(id);
    List<Chapter> chaps = [];
    for(var r in res){
      Chapter c = Chapter(r['name'], r['url'], r['source_order'], r['chapter_number'], chapterId: r['id'], mangaId: r['manga_id'], uploadDate: r['date_upload'], read: r['read'], download: r['download']);
      chaps.add(c);
    }
    return chaps;
  }

}
