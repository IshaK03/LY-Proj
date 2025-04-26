import 'package:flutter/material.dart';
import 'package:frontend/pages/chatpage.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/prescription_summary.dart';
import 'package:frontend/pages/scan.dart';

class BottomNavbar extends StatefulWidget {
  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    HomeScreen(),
    ChatApp(),
    ScanPage(),
    PrescriptionSummary()
  ];

  // Handle navigation internally within the widget
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index without navigating
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Display the selected page in the body
          IndexedStack(
            index: _selectedIndex,
            children: _pages, // Stack of all pages
          ),
          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Color(0xFF121212), // Dark color for the navbar background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors
                    .transparent, // Transparent so the container color shows
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.blueAccent, // Color for selected item
                unselectedItemColor: Colors.white, // Color for unselected items
                selectedFontSize: 14, // Adjusted font size
                unselectedFontSize: 12,
                onTap: _onItemTapped,
                items: [
                  // Wrap each BottomNavigationBarItem with InkWell
                  BottomNavigationBarItem(
                    icon: InkWell(
                      splashColor: Colors.transparent, // Color of splash effect
                      onTap: () => _onItemTapped(0), // Handle the tap
                      child: Icon(Icons.home),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      splashColor: Colors.transparent, // Color of splash effect
                      onTap: () => _onItemTapped(1), // Handle the tap
                      child: Icon(Icons.chat),
                    ),
                    label: 'ChatBot',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      splashColor: Colors.transparent, // Color of splash effect
                      onTap: () => _onItemTapped(2), // Handle the tap
                      child: Icon(Icons.camera_alt),
                    ),
                    label: 'Scan',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      splashColor: Colors.transparent, // Color of splash effect
                      onTap: () => _onItemTapped(3), // Handle the tap
                      child: Icon(Icons.medical_services_outlined),
                    ),
                    label: 'Prescriptions',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
