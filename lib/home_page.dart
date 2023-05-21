import 'package:flutter/material.dart';
import 'library.dart';
import 'browse.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedView = 0;
  final List<Widget> pages = [
    const Library(),
    const Browse(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedView = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedView],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFD070725),
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color(0xDBFFFFFF),
        currentIndex: selectedView,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Browse',
          ),
        ],
      ),
    );
  }
}
