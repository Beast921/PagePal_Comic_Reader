import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_shit/search_results.dart';
import 'package:test_shit/tile.dart';
import 'bato.dart';
import 'details.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchBarController = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool loading = false;
  String str = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
  }

  void clearSearch() {
    setState(() {
      searchBarController.clear();
    });
  }

  void performSearch(String query) async {
    results.clear();
    loading = true;
    setState(() {});
    Map<String, dynamic> res = {};
    res['source'] = 'Bato.to';
    res['result'] = await Bato.search(query);
    results.add(res);
    str = query;
    loading = false;
    setState(() {});
  }

  Widget resTile(Tile t) {
    return InkResponse(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(t.url)),
        );
      },
      child: Container(
        height: 130,
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              color: Colors.black,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
              child: GridTile(
                child: t.coverUrl.isNotEmpty
                    ? Image.network(t.coverUrl, height: 120, width: 100, fit: BoxFit.cover)
                    : const SizedBox(
                  height: 30,
                  child: Icon(
                    Icons.book_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            Text(
              t.title,
              style: const TextStyle(color: Color(0xDBFFFFFF), fontSize: 13, fontWeight: FontWeight.normal),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070725),
      appBar: AppBar(
        leading: const BackButton(color: Color(0xDBFFFFFF)),
        title: TextField(
          controller: searchBarController,
          autofocus: true,
          style: const TextStyle(
            color: Color(0xDBFFFFFF),
            fontSize: 22,
            fontWeight: FontWeight.normal
          ),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: const TextStyle(color: Color(0xBD9E9E9E)),
            border: InputBorder.none,
            suffixIcon: searchBarController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: clearSearch,
              color: const Color(0xDBFFFFFF),
              iconSize: 26,
            )
                : null,
          ),
          onChanged: (String query) {
            setState(() {});
          },
          onSubmitted: (String query) {
            performSearch(query);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { performSearch(searchBarController.text); },
            color: const Color(0xDBFFFFFF),
            iconSize: 26,
          )
        ],
        backgroundColor: const Color(0xFF070725),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF093E9F)))
          : ListView.builder(
        itemCount: results.length,
        physics: const ScrollPhysics(),
        itemBuilder: (BuildContext context, int index){
          final Map<String, dynamic> item = results[index];
          final title = item['source'];
          final List<Tile> items = item['result'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(color: Color(0xDBFFFFFF), fontSize: 20),
                  ),
                  trailing: const Icon(Icons.arrow_forward, size: 24, color: Color(0xDBFFFFFF)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchResult(title, str, items)),
                    );
                  },
                ),
                items.isEmpty
                    ? const SizedBox(
                  height: 30,
                  child: Text(
                    'No results found.',
                    style: TextStyle(color: Color(0xA4FFFFFF),fontSize: 18),
                  )
                )
                    : SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: min(10, items.length),
                    itemBuilder: (BuildContext context, int index) {
                      return resTile(items[index]);
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
