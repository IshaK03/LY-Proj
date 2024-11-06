// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:frontend/pages/chatpage.dart';
// import 'package:frontend/pages/signUp.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = FirebaseAuth.instance;
//     final user = auth.currentUser; // Fetch the current user

//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xff4b6cb7), Color(0xff182848)],
//             stops: [0, 1],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Check if user is not null, then display the email
//             Text(
//               'Welcome to Home Screen, ${user?.email ?? 'User'}', // Shows 'User' if no email is found
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),

//             // Logout Button
//             ElevatedButton(
//               onPressed: () {
//                 auth.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignUp()),
//                 );
//               },
//               child: const Text('Sign Out'),
//             ),

//             const SizedBox(height: 20),
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const ChatApp(),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 height: MediaQuery.of(context).size.height * 0.2,
//                 decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 66, 129, 223),
//                     borderRadius: BorderRadius.circular(25)),
//                 child: const Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     "ChatBot",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/pages/chatpage.dart';
import 'package:frontend/pages/signUp.dart';
import 'package:frontend/reusable_widgets/bottomNavbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ChatApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xff182848),
      ),
      body: Stack(
        children: [
          // Main Background Container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff4b6cb7), Color(0xff182848)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120), // Space for floating elements

                // // Display the email if available
                // Text(
                //   'Welcome to Home Screen, ${user?.email ?? 'User'}',
                //   style: const TextStyle(fontSize: 16, color: Colors.white),
                // ),
                // const SizedBox(height: 20),

                //// Logout Button
                // ElevatedButton(
                //   onPressed: () {
                //     auth.signOut();
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => const SignUp()),
                //     );
                //   },
                //   child: const Text('Sign Out'),
                // ),
                // const SizedBox(height: 20),

                // // ChatBot Navigation Button
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(builder: (context) => const ChatApp()),
                //     );
                //   },
                //   child: Container(
                //     width: MediaQuery.of(context).size.width * 0.5,
                //     height: MediaQuery.of(context).size.height * 0.2,
                //     decoration: BoxDecoration(
                //       color: const Color.fromARGB(255, 66, 129, 223),
                //       borderRadius: BorderRadius.circular(25),
                //     ),
                //     child: const Align(
                //       alignment: Alignment.center,
                //       child: Text(
                //         "ChatBot",
                //         style: TextStyle(color: Colors.white),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          // Floating Medication Reminders
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Container(
              width: MediaQuery.of(context).size.width -
                  30, // Ensures the same width
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 50, // Reduced height for each card
                    child: _reminderCard("Medication ${index + 1}"),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8), // Slightly reduced spacing
                itemCount: 10, // Ensure exactly 10 items visible
              ),
            ),
          ),

// Daily Affirmations Section
          Positioned(
            top: 330,
            left: 15, // Match the left padding of the first box
            right: 15, // Match the right padding of the first box
            child: Container(
              width: MediaQuery.of(context).size.width -
                  30, // Match the same width as the ListView container
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 32), // Padding inside container
                child: const Text(
                  "Daily Affirmations Meow Meow Meow Meow Meow Meow",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Emergency Button
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                // Action for Emergency button
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Emergency",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Medication reminder card widget
  Widget _reminderCard(String title) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
