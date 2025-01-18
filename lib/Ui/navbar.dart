import 'package:firestore_basics/Ui/app_features.dart';
import 'package:flutter/material.dart';
import 'package:firestore_basics/Ui/homepage.dart';
import 'package:firestore_basics/Ui/profile.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavbarState();
}

class _NavbarState extends State<NavBar> {
  int _currentIndex = 0;
  final List<Widget> screens = [
    //eto yung sa kada screen tas naka index sya
    Landingpage(),
    AppFeatures(),
    AddScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //eto yung sa addscreen dapat para ma full screen tas mawawala nav bar
      body: _currentIndex ==
              2 // Check if the selected index is 2 or yung add icon yung pinisa sa nav bar saka sya mag fufull screen
          ? Container() // Show an empty container or some other content
          : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          if (newIndex == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          } else {
            setState(() {
              _currentIndex = newIndex; // Update current index for other items
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Color(0xFFA52424),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Screen')),
      body: Center(
        child: Text('This is the Menu Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class AddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Screen')),
      body: Center(
        child: Text('This is the Add Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages Screen')),
      body: Center(
        child:
            Text('This is the Messages Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Text('This is the Home Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
