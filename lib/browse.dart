import 'package:flutter/material.dart';
import 'package:test_shit/search.dart';
import 'package:test_shit/source_latest.dart';
import 'bato.dart';

class Browse extends StatefulWidget {
  const Browse({Key? key}) : super(key: key);

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  final List<Map<String, Function>> sources = [{'Bato.to': Bato.getLatest}];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070725),
      appBar: AppBar(
        title: const Text(
          'Browse',
          style: TextStyle(color: Color(0xDBFFFFFF), fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Search()),
              );
            },
            icon: const Icon(Icons.travel_explore),
            color: const Color(0xDBFFFFFF),
            iconSize: 26,
          )
        ],
        backgroundColor: const Color(0xFF070725),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(18.0, 30.0, 18.0, 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'Sources',
                style: TextStyle(color: Color(0xDBFFFFFF), fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const ScrollPhysics(),
                itemCount: sources.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, Function> item = sources[index];
                  String name = '';
                  Function? func;
                  for(var v in item.keys){
                    name = v;
                    func = item[v];
                  }
                  return ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(color: Color(0xDBFFFFFF), fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SourceLatest(name ?? '', func!)),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
