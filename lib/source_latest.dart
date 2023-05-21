import 'package:flutter/material.dart';
import 'package:test_shit/tile.dart';
import 'manga_grid.dart';
import 'bato.dart';

class SourceLatest extends StatefulWidget {
  const SourceLatest(this.name, this.func, {Key? key}) : super(key: key);
  final Function func;
  final String name;

  @override
  State<SourceLatest> createState() => _SourceLatestState();
}

class _SourceLatestState extends State<SourceLatest> {
  late Function func;
  String name = '';
  bool loading = true;
  List<Tile> items = [];

  @override
  void initState(){
    super.initState();
    name = widget.name;
    func = widget.func;
    getInfo();
  }

  Future<void> getInfo() async {
    items = await func();
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070725),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070725),
        title: Text(
          name,
          style: const TextStyle(color: Color(0xDBFFFFFF), fontSize: 22),
        ),
        leading: const BackButton(color: Color(0xDBFFFFFF)),
      ),
      body: loading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF093E9F)))
      : MangaGrid(items),
    );
  }
}
