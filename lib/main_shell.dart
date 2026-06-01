import 'package:flutter/material.dart';

import 'features/about/about_page.dart';
import 'features/bookmarks/bookmarks_page.dart';
import 'features/contribute/contribute_page.dart';
import 'features/home/home_page.dart';
import 'features/search/search_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    BookmarksPage(),
    ContributePage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool get _showFab => _selectedIndex != 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.volunteer_activism),
              label: const Text('Contribute'),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        height: 72,
        indicatorColor: const Color(0xFFE3F2FD),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Contribute',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}