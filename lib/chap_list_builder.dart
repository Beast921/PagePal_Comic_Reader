import 'package:test_shit/chapter.dart';
import 'package:flutter/material.dart';
import 'package:test_shit/reader.dart';

class ChapListBuilder extends StatelessWidget {
  final List<Chapter>? chapters;
  final String mangaName;
  const ChapListBuilder({required this.chapters, required this.mangaName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00031BFF),
      body: ListView.builder(
        physics: const ScrollPhysics(),
        itemCount: chapters?.length,
        itemBuilder: (_, int index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Reader(chapters!, index, mangaName)),
                );
              },
              dense: true,
              visualDensity: const VisualDensity(vertical: 0),
              contentPadding: const EdgeInsets.only(left: 10, right: 5),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_circle_down_outlined, color: Colors.white54),
              ),
              title: Text(
                chapters?[index].name ?? '',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                chapters?[index].uploadDate ?? '',
                style: const TextStyle(
                  color: Colors.white24,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          );
        },
      ),
    );
  }
}