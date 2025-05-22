import 'package:alhy_momken_task/features/home/ui/widgets/book_marks.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/collections.dart';
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

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> collections = [
      {'title': 'Inspiration', 'items': 32, 'icon': Icons.emoji_emotions},
      {'title': 'Catboosters', 'items': 163, 'icon': Icons.pets},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},

    ];
    final List<Widget> _screens = [
      HomeScreen(),
      BookMarks(),
      Container(),
      Collections(),
      Settings(),

    ];
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items:  [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: "Home"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bookmark), label: "Bookmarks"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.plus,size: 32,), label: ""),
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
