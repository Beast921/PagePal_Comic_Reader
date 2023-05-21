import 'package:flutter/material.dart';
import 'package:test_shit/manga_grid.dart';
import 'package:test_shit/tile.dart';
import 'db_helper.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<Tile> mangas = [];

  @override
  void initState() {
    super.initState();
    getManga();
  }

  void getManga() async {
    mangas = await DBStuff().getFavouriteMangas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070725),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(color: Color(0xDBFFFFFF), fontSize: 22),
        ),
        backgroundColor: const Color(0xFF070725),
      ),
      body: MangaGrid(mangas),
    );
  }
}
