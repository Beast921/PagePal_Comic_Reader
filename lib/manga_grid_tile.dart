import 'package:flutter/material.dart';
import 'package:test_shit/tile.dart';

import 'details.dart';

class MangaGridTile extends StatelessWidget {
  const MangaGridTile(this.t, {Key? key}) : super(key: key);
  final Tile t;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(t.url, mId: t.id,)),
        );
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.4 * 1.5,
        width: MediaQuery.of(context).size.width * 0.4,
        child: Card(
          color: Colors.black,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
          child: GridTile(
            footer: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: true,
              title: Text(
                t.title,
                style: const TextStyle(color: Color(0xAEFFFFFF), fontSize: 14, fontWeight: FontWeight.normal),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            child: t.coverUrl.isNotEmpty
            ? Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  width: 0,
                  color: const Color(0xFF070725),
                ),
                // boxShadow: [BoxShadow(color: const Color(0xFF070725).withOpacity(.5))],
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF070725).withOpacity(0),
                    const Color(0xFF070725).withOpacity(0.4),
                    const Color(0xFF070725).withOpacity(0.9),
                  ],
                ),
              ),
              child: Image.network(t.coverUrl, fit: BoxFit.cover),
            )
            : SizedBox(
              height: MediaQuery.of(context).size.width * 1.5,
              child: Icon(
                Icons.book_rounded,
                color: Colors.grey,
                size: MediaQuery.of(context).size.width * .2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
