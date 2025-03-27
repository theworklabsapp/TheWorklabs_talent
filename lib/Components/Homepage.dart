import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int currentIndex = 0;

  // Define the pages for each tab
  final List<Widget> _pages = [
    const Center(child: Text('Welcome to the Home Page!')),
  ];

  void _onTabTapped(int index) {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                if (user != null)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  ),
              ],
            ),
            body: _pages[currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: _onTabTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
