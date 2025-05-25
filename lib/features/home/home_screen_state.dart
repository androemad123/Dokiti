import 'package:alhy_momken_task/features/home/ui/widgets/bookmark_screen.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/collections_screen.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/home_screen.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<HomeScreenState> createState() => _HomeScreenStateState();
}

class _HomeScreenStateState extends State<HomeScreenState> {
  int _selectedIndex = 0;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(),
      BookmarksScreen(),
      CollectionsScreen(),
      SettingsScreen(),

    ];
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items:  [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: "Home"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bookmark), label: "Bookmarks"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.folder), label: "Collections"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.gear), label: "Settings"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

      ),
    );
  }
}
