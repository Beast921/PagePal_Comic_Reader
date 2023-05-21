import 'package:test_shit/tile.dart';

import 'manga_grid_tile.dart';
import 'package:flutter/material.dart';

class MangaGrid extends StatelessWidget {
  const MangaGrid(this.items, {Key? key}) : super(key: key);
  final List<Tile> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2/3,
        ),
        itemBuilder: (BuildContext context, int index) {
          return MangaGridTile(items[index]);
        },
      ),
    );
  }
}
