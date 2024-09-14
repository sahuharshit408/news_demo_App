import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/home_screen.dart';
import 'Screens/settings_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  List<BottomNavigationBarItem> bottomOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBottomTrayOptions();
  }

  void fetchBottomTrayOptions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bottom_tray_options')
          .doc('options')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;

        List<String> options = [
          data['Option_1'] ?? 'Settings',
          data['Option_2'] ?? 'Categories',
          data['Option_3'] ?? 'Home',
          data['Option_4'] ?? 'Discover',
          data['Option_5'] ?? 'Profile',
        ];

        setState(() {
          bottomOptions = options.asMap().entries.map((entry) {
            int idx = entry.key;
            String label = entry.value;

            IconData icon = Icons.home;

            switch (idx) {
              case 0:
                icon = Icons.settings;
                break;
              case 1:
                icon = Icons.category;
                break;
              case 2:
                icon = Icons.home;
                break;
              case 3:
                icon = Icons.explore;
                break;
              case 4:
                icon = Icons.person;
                break;
            }

            return BottomNavigationBarItem(
              icon: Icon(icon),
              label: label,
            );
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching bottom tray options: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: bottomOptions,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SettingsScreen(),
          const Center(child: Text('Categories Screen')),
          const HomeScreen(),
          const Center(child: Text('Discover Screen')),
          const Center(child: Text('Profile Screen')),
        ],
      ),
    );
  }
}
