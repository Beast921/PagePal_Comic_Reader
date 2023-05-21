import 'dart:developer';
import 'package:test_shit/chapter.dart';
import 'package:test_shit/manga.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class Manganelo {
  static Manga? mangaDetails(String? html, String baseUrl){
    try{
      final soup = BeautifulSoup(html as String);
      final thumbnailUrl = soup.find('div', class_: 'story-info-left')?.find('img', class_: 'img-loading')?.attributes['src'] ?? '';
      final info = soup.find('div', class_: 'story-info-right');
      final title = info?.find('h1')?.text ?? '';
      final table = info?.find('table')?.findAll('tr');
      final status = table![2].find('td', class_: 'table-value')?.text ?? '';
      List<String> author = [];
      final authors = table[1].find('td', class_: 'table-value')?.findAll('a');
      for(var a in authors!){
        author.add(a.text);
      }
      List<String> genres = [];
      final genreList = table[3].find('td', class_: 'table-value')?.findAll('a');
      for(var genre in genreList!){
        genres.add(genre.text);
      }
      final description = soup.find('div', id: 'panel-story-info-description')?.text ?? '';

      Manga manga = Manga(
          title, 'Manganelo',
          baseUrl,
          thumbnailUrl,
          status,
          description,
          author,
          genres
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
      final items = soup.find('ul', class_: 'row-content-chapter');
      final list = items?.findAll('li');
      int i=1;
      for(final item in list!){
        final name = item.find('a')?.text ?? '';
        final url = item.find('a')?.attributes['href'] ?? '';
        final uploadDate = item.find('span', class_: 'chapter-time text-nowrap')?.text ?? '';
        final chapNum = item.attributes['id'];
        final chapterNumber = int.parse(chapNum!.replaceAll(RegExp('[^0-9]'), ''));
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

  static List<String> getImages(String? html) {
    List<String> imageUrls = [];
    try{
      final soup = BeautifulSoup(html as String);
      final items = soup.find('div', class_: 'container-chapter-reader');
      final list = items?.findAll('img', class_: 'reader-content');
      for(final item in list!){
        final image = item.attributes['src'] ?? '';
        imageUrls.add(image);
      }
      return imageUrls;
    } catch(e) {
      log('getImages => $e');
    }
    return imageUrls;
  }
}