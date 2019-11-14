import 'package:flutter/material.dart';
import 'package:warehouser/utils/colors.dart';
import 'package:warehouser/views/tabs/products.dart';
import 'package:warehouser/views/tabs/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProfilePage(),
    ProductsPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBar = BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.withOpacity(0.6),
      elevation: 0.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          title: Text(
            'Products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    return Scaffold(
        bottomNavigationBar: bottomNavBar,
        body: _pages[_currentIndex],
    );
  }
}
