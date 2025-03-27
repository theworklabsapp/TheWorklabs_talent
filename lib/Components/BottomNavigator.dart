import 'package:flutter/material.dart';
import 'package:my_flutter_app/Jobs/ListAllJobs.dart';
import 'package:my_flutter_app/Jobs/SearchJob.dart';
import 'package:my_flutter_app/Jobs/PostAJob.dart';
import 'package:my_flutter_app/Profile%20Components/ProfilePage.dart';

class BottomNavigatorExample extends StatefulWidget {
  const BottomNavigatorExample({super.key});

  @override
  _BottomNavigatorExampleState createState() => _BottomNavigatorExampleState();
}

class _BottomNavigatorExampleState extends State<BottomNavigatorExample> {
  int _selectedIndex = 0;
  List<Widget> widgetOptions = [
    jobsList(),
    JobSearchPage(),
    JobPostingPage(),
    JobProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.blue,
      ),
      child: Scaffold(
        body: widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Category',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Person',
          ),
        ], onTap: _onItemTapped, currentIndex: _selectedIndex),
      ),
    );
  }
}
