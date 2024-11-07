import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/medication_reminder.dart';
import 'package:frontend/pages/signin.dart';
import 'package:frontend/providers/medicationProvider.dart';
import 'package:frontend/reusable_widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> fetchAffirmation() async {
    final response = await http.get(Uri.parse('https://www.affirmations.dev/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['affirmation'] ?? 'No affirmation available';
    } else {
      throw Exception('Failed to load affirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(76, 123, 238, 1),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff4b6cb7), Color(0xff182848)],
                stops: [0, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Patient Dashboard",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Your Prescriptions for Today",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Consumer<MedicationProvider>(
                    builder: (context, provider, _) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.medications.length,
                        itemBuilder: (context, index) {
                          final reminder = provider.medications[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  reminder.name,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                subtitle: Text(
                                  'Time: ${reminder.time} - Dosage: ${reminder.dosage}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.black),
                                      onPressed: () {
                                        _showEditDialog(
                                            context, provider, reminder, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        provider.removeMedication(reminder);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Use FutureBuilder to fetch and display the affirmation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    child: FutureBuilder<String>(
                      future: fetchAffirmation(), // Call the API
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                            "Error loading affirmation",
                            style: TextStyle(color: Colors.white),
                          );
                        } else if (snapshot.hasData) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Daily Affirmation: ${snapshot.data}",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          return const Text(
                            "No affirmation available",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // Emergency action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          "Emergency",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

void _showAddDialog(BuildContext context) {
  final nameController = TextEditingController();
  final timeController = TextEditingController();
  final dosageController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newReminder = MedicationReminder(
                name: nameController.text,
                time: timeController.text,
                dosage: dosageController.text,
              );
              Provider.of<MedicationProvider>(context, listen: false)
                  .addMedication(newReminder);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

// Function to show the Edit Medication dialog
void _showEditDialog(BuildContext context, MedicationProvider provider,
    MedicationReminder reminder, int index) {
  final nameController = TextEditingController(text: reminder.name);
  final timeController = TextEditingController(text: reminder.time);
  final dosageController = TextEditingController(text: reminder.dosage);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedReminder = MedicationReminder(
                name: nameController.text,
                time: timeController.text,
                dosage: dosageController.text,
              );
              provider.updateMedication(index, updatedReminder);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}



// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:frontend/pages/chatpage.dart';
// import 'package:frontend/pages/signUp.dart';
// import 'package:frontend/reusable_widgets/bottomNavbar.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final auth = FirebaseAuth.instance;
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     if (index == 1) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => const ChatApp()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         backgroundColor: const Color(0xff182848),
//       ),
//       body: Stack(
//         children: [
//           // Main Background Container
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xff4b6cb7), Color(0xff182848)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 120), // Space for floating elements

//                 // // Display the email if available
//                 // Text(
//                 //   'Welcome to Home Screen, ${user?.email ?? 'User'}',
//                 //   style: const TextStyle(fontSize: 16, color: Colors.white),
//                 // ),
//                 // const SizedBox(height: 20),

//                 //// Logout Button
//                 // ElevatedButton(
//                 //   onPressed: () {
//                 //     auth.signOut();
//                 //     Navigator.pushReplacement(
//                 //       context,
//                 //       MaterialPageRoute(builder: (context) => const SignUp()),
//                 //     );
//                 //   },
//                 //   child: const Text('Sign Out'),
//                 // ),
//                 // const SizedBox(height: 20),

//                 // // ChatBot Navigation Button
//                 // InkWell(
//                 //   onTap: () {
//                 //     Navigator.of(context).push(
//                 //       MaterialPageRoute(builder: (context) => const ChatApp()),
//                 //     );
//                 //   },
//                 //   child: Container(
//                 //     width: MediaQuery.of(context).size.width * 0.5,
//                 //     height: MediaQuery.of(context).size.height * 0.2,
//                 //     decoration: BoxDecoration(
//                 //       color: const Color.fromARGB(255, 66, 129, 223),
//                 //       borderRadius: BorderRadius.circular(25),
//                 //     ),
//                 //     child: const Align(
//                 //       alignment: Alignment.center,
//                 //       child: Text(
//                 //         "ChatBot",
//                 //         style: TextStyle(color: Colors.white),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           // Floating Medication Reminders
//           Positioned(
//             top: 20,
//             left: 15,
//             right: 15,
//             child: Container(
//               width: MediaQuery.of(context).size.width -
//                   30, // Ensures the same width
//               height: 300,
//               child: ListView.separated(
//                 scrollDirection: Axis.vertical,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//                 itemBuilder: (context, index) {
//                   return SizedBox(
//                     height: 50, // Reduced height for each card
//                     child: _reminderCard("Medication ${index + 1}"),
//                   );
//                 },
//                 separatorBuilder: (context, index) =>
//                     const SizedBox(height: 8), // Slightly reduced spacing
//                 itemCount: 10, // Ensure exactly 10 items visible
//               ),
//             ),
//           ),

// // Daily Affirmations Section
//           Positioned(
//             top: 330,
//             left: 15, // Match the left padding of the first box
//             right: 15, // Match the right padding of the first box
//             child: Container(
//               width: MediaQuery.of(context).size.width -
//                   30, // Match the same width as the ListView container
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 32), // Padding inside container
//                 child: const Text(
//                   "Daily Affirmations Meow Meow Meow Meow Meow Meow",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),

//           // Emergency Button
//           Positioned(
//             bottom: 80,
//             left: 16,
//             right: 16,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Action for Emergency button
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "Emergency",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Medication reminder card widget
//   Widget _reminderCard(String title) {
//     return Container(
//       width: 120,
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           title,
//           style: const TextStyle(color: Colors.white),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
