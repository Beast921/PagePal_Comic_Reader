import 'package:flutter/material.dart';
import 'package:test_shit/manga_grid.dart';
import 'tile.dart';

class SearchResult extends StatelessWidget {
  const SearchResult(this.source, this.query, this.results, {Key? key}) : super(key: key);
  final String source, query;
  final List<Tile> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070725),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070725),
        leading: const BackButton(color: Color(0xDBFFFFFF)),
        title: Text(
          '$source - \'$query\'',
          style: const TextStyle(color: Color(0xDBFFFFFF), fontSize: 22, fontWeight: FontWeight.normal),
        ),
      ),
      body: MangaGrid(results),
    );
  }
}
