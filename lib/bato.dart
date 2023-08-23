import 'dart:convert';
import 'dart:developer';
import 'package:test_shit/chapter.dart';
import 'package:test_shit/manga.dart';
import 'package:test_shit/http_request.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'tile.dart';

class Bato {
  static String srcUrl = 'http://15.207.84.148';
  // static String srcUrl = 'http://10.0.2.2:5000';

  static Manga? mangaDetails(String? html, String baseUrl){
    try{
      final soup = BeautifulSoup(html as String);
      final thumbnailUrl = soup.find('div', class_: 'attr-cover')?.find('img', class_: 'shadow-6')?.attributes['src'] ?? '';
      final title = soup.find('h3', class_: 'item-title')?.find('a')?.text ?? '';
      final info = soup.find('div', class_: 'attr-main');
      var status = '';
      final attrs = info?.findAll('div', class_: 'attr-item');
      List<String> author = [], artist = [], genres = [];
      for(var attr in attrs!){
        var b = attr.find('b', class_: 'text-muted')?.text ?? '';
        if(b == 'Authors:'){
          var authors = attr.findAll('a');
          for(var a in authors){
            author.add(a.text);
          }
        }
        if(b == 'Artists:'){
          var artists = attr.findAll('a');
          for(var a in artists){
            artist.add(a.text);
          }
        }
        if(b == 'Genres:'){
          var g = attr.find('span')?.findAll('u');
          for(var genre in g!){
            genres.add(genre.text);
          }
          g = attr.find('span')?.findAll('b');
          for(var genre in g!){
            genres.add(genre.text);
          }
          g = attr.find('span')?.findAll('span');
          for(var genre in g!){
            genres.add(genre.text);
          }
        }
        if(b == 'Original work:'){
          status = attr.find('span')?.text ?? '';
        }
      }

      final description = info?.find('div', id: 'limit-height-body-summary')?.find('div', class_: 'limit-html')?.text ?? '';

      Manga manga = Manga(
          title, 'Bato.to',
          baseUrl,
          thumbnailUrl,
          status,
          description,
          author,
          genres,
          artist: artist,
      );

      return manga;

    } catch(e) {
      log('mangaDetails => $e');
    }
    return null;
  }

  static List<Chapter> chapterDetails(String? html){
    List<Chapter> chapters = [];
    try{
      final soup = BeautifulSoup(html as String);
      final items = soup.find('div', class_: 'mt-4 episode-list');
      final list = items?.findAll('div', class_: 'p-2 d-flex flex-column flex-md-row item');
      int i=1;
      final total = items?.find('div', class_: 'head')?.find('h4')?.text;
      final totalChap = int.parse(total!.replaceAll(RegExp('[^0-9]'), ''));
      for(final item in list!){
        final name = item.find('a')?.find('b')?.text ?? '';
        var url = item.find('a')?.attributes['href'] ?? '';
        url = 'https://bato.to$url';
        final uploadDate = item.find('i', class_: 'ps-3')?.text ?? '';
        final chapterNumber = totalChap - i + 1;
        Chapter chapter = Chapter(name, url, i, chapterNumber, uploadDate: uploadDate);
        chapters.add(chapter);
        ++i;
      }
      return chapters;
    } catch(e) {
      log('chapterDetails => $e');
    }
    return chapters;
  }

  static Future<List<String>> fetchImages(String? chapUrl) async {
    final url = '$srcUrl/fetchImg?query=$chapUrl';
    final res = await HttpService.get(url);
    final Map parsed = json.decode(res!);
    List<String> images = [];
    List data = parsed['images'];
    for(var item in data){
      images.add(item.toString());
    }
    return images;
  }

  static Future<List<Tile>> search(String? keyword) async {
    final url = '$srcUrl/search?query=$keyword';
    final res = await HttpService.get(url);
    final parsed = json.decode(res!);
    List<Tile> results = [];
    for(Map<String, dynamic> data in parsed){
      final tile = Tile.fromJson(data);
      results.add(tile);
    }
    return results;
  }

  static Future<List<Tile>> getLatest() async {
    final url = '$srcUrl/latest';
    final res = await HttpService.get(url);
    final parsed = json.decode(res!);
    List<Tile> results = [];
    for(Map<String, dynamic> data in parsed){
      final tile = Tile.fromJson(data);
      results.add(tile);
    }
    return results;
  }
}