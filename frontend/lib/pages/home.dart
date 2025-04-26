import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/medication_reminder.dart';
import 'package:frontend/pages/signin.dart';
import 'package:frontend/providers/medicationProvider.dart';
import 'package:frontend/reusable_widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Container(
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
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Patient Dashboard",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Your Prescriptions for Today",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),

              // Reminders ListView inside a fixed-height Container
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Consumer<MedicationProvider>(
                      builder: (context, provider, _) {
                        return ListView.builder(
                          itemCount: provider.medicationReminders.length,
                          itemBuilder: (context, index) {
                            final reminder =
                                provider.medicationReminders[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    reminder.name,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    'Date & Time: ${reminder.dateTime.toLocal()}\nDosage: ${reminder.dosage}',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.black),
                                        onPressed: () {
                                          _showEditDialog(
                                              context, provider, reminder);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          provider.deleteReminder(reminder.id);
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
                  ),
                ),
              ),

              // Affirmation Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                child: FutureBuilder<String>(
                  future: fetchAffirmation(), // Call the API
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
              const SizedBox(height: 10),

              // Emergency Button and Floating Action Button for adding medication
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Emergency action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    icon: const Icon(
                      Icons.notification_important_sharp,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Emergency",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: () => _showAddDialog(context),
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add new medication reminder dialog
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dateTimeController = TextEditingController();
    final dosageController = TextEditingController();

    DateTime selectedDateTime = DateTime.now();

    Future<void> _selectDateTime(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );

        if (pickedTime != null) {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          dateTimeController.text = selectedDateTime.toLocal().toString();
        }
      }
    }

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
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateTimeController,
                    decoration: const InputDecoration(labelText: 'Date & Time'),
                  ),
                ),
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
                  id: DateTime.now().toString(), // Use current timestamp as ID
                  name: nameController.text,
                  dateTime: selectedDateTime, // Store DateTime directly
                  dosage: dosageController.text,
                );
                context.read<MedicationProvider>().addReminder(newReminder);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, MedicationProvider provider,
      MedicationReminder reminder) {
    final nameController = TextEditingController(text: reminder.name);
    final dateTimeController =
        TextEditingController(text: reminder.dateTime.toLocal().toString());
    final dosageController = TextEditingController(text: reminder.dosage);

    DateTime selectedDateTime = reminder.dateTime;

    Future<void> _selectDateTime(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );

        if (pickedTime != null) {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          dateTimeController.text = selectedDateTime.toLocal().toString();
        }
      }
    }

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
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateTimeController,
                    decoration: const InputDecoration(labelText: 'Date & Time'),
                  ),
                ),
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
                final editedReminder = MedicationReminder(
                  id: reminder.id,
                  name: nameController.text,
                  dateTime: selectedDateTime, // Store DateTime directly
                  dosage: dosageController.text,
                );
                provider.editMedication(editedReminder);
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:frontend/models/medication_reminder.dart';
// import 'package:frontend/pages/signin.dart';
// import 'package:frontend/providers/medicationProvider.dart';
// import 'package:frontend/reusable_widgets/drawer.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   Future<String> fetchAffirmation() async {
//     final response = await http.get(Uri.parse('https://www.affirmations.dev/'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       return data['affirmation'] ?? 'No affirmation available';
//     } else {
//       throw Exception('Failed to load affirmation');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = FirebaseAuth.instance;
//     final user = auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         centerTitle: true,
//         backgroundColor: Color.fromRGBO(76, 123, 238, 1),
//       ),
//       drawer: const CustomDrawer(),
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
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               "Patient Dashboard",
//               style:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               "Your Prescriptions for Today",
//               style: TextStyle(color: Colors.white),
//             ),
//             const SizedBox(height: 4),

//             // Reminders ListView inside a fixed-height Container
//             SizedBox(
//               height: 300,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                   child: Consumer<MedicationProvider>(
//                     builder: (context, provider, _) {
//                       return ListView.builder(
//                         itemCount: provider.medications.length,
//                         itemBuilder: (context, index) {
//                           final reminder = provider.medications[index];
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14.0, vertical: 10.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12.0),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.5),
//                                     spreadRadius: 2,
//                                     blurRadius: 5,
//                                     offset: Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: ListTile(
//                                 title: Text(
//                                   reminder.name,
//                                   style: const TextStyle(color: Colors.black),
//                                 ),
//                                 subtitle: Text(
//                                   'Time: ${reminder.dateTime}  Dosage: ${reminder.dosage}',
//                                   style: const TextStyle(color: Colors.black54),
//                                 ),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.edit,
//                                           color: Colors.black),
//                                       onPressed: () {
//                                         _showEditDialog(
//                                             context, provider, reminder, index);
//                                       },
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete,
//                                           color: Colors.red),
//                                       onPressed: () {
//                                         provider.removeMedication(reminder);
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),

//             // Affirmation Section
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
//               child: FutureBuilder<String>(
//                 future: fetchAffirmation(), // Call the API
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return const Text(
//                       "Error loading affirmation",
//                       style: TextStyle(color: Colors.white),
//                     );
//                   } else if (snapshot.hasData) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: const Color.fromRGBO(255, 255, 255, 0.2),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         "Daily Affirmation: ${snapshot.data}",
//                         style: const TextStyle(
//                           color: Color.fromARGB(255, 255, 255, 255),
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     );
//                   } else {
//                     return const Text(
//                       "No affirmation available",
//                       style: TextStyle(color: Colors.white),
//                     );
//                   }
//                 },
//               ),
//             ),
//             SizedBox(height: 10),
//             // Emergency Button
//             Positioned(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       // Emergency action
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                     ),
//                     icon: const Icon(
//                       Icons.notification_important_sharp, // Choose an appropriate icon
//                       color: Colors.white,
//                     ),
//                     label: const Text(
//                       "Emergency",
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   FloatingActionButton(
//                     onPressed: () => _showAddDialog(context),
//                     child: const Icon(Icons.add),
//                     backgroundColor: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void _showAddDialog(BuildContext context) {
//   final nameController = TextEditingController();
//   final dateTimeController = TextEditingController(); // For display
//   final dosageController = TextEditingController();

//   DateTime selectedDateTime = DateTime.now();

//   // Function to pick both date and time
//   Future<void> _selectDateTime(BuildContext context) async {
//     final DateTime? pickedDateTime = await showDatePicker(
//       context: context,
//       initialDate: selectedDateTime,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     ).then((pickedDate) async {
//       if (pickedDate != null) {
//         final TimeOfDay? pickedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.fromDateTime(selectedDateTime),
//         );
//         if (pickedTime != null) {
//           // Combine the selected date and time
//           selectedDateTime = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//           dateTimeController.text =
//               '${selectedDateTime.toLocal()}'.split(' ')[0] +
//                   ' ${pickedTime.format(context)}';
//         }
//       }
//     });
//   }

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Add Medication'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             GestureDetector(
//               onTap: () => _selectDateTime(context), // DateTime picker
//               child: AbsorbPointer(
//                 // Prevents text input, uses date picker
//                 child: TextField(
//                   controller: dateTimeController,
//                   decoration: const InputDecoration(labelText: 'Date & Time'),
//                 ),
//               ),
//             ),
//             TextField(
//               controller: dosageController,
//               decoration: const InputDecoration(labelText: 'Dosage'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               final newReminder = MedicationReminder(
//                 name: nameController.text,
//                 dateTime: dateTimeController.text, // Store formatted datetime
//                 dosage: dosageController.text,
//               );
//               Provider.of<MedicationProvider>(context, listen: false)
//                   .addMedication(newReminder);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       );
//     },
//   );
// }

// // Function to show the Edit Medication dialog
// void _showEditDialog(BuildContext context, MedicationProvider provider,
//     MedicationReminder reminder, int index) {
//   final nameController = TextEditingController(text: reminder.name);
//   final dateTimeController = TextEditingController(text: reminder.dateTime);
//   final dosageController = TextEditingController(text: reminder.dosage);

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Edit Reminder'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: dateTimeController,
//               decoration: const InputDecoration(labelText: 'Date & Time'),
//             ),
//             TextField(
//               controller: dosageController,
//               decoration: const InputDecoration(labelText: 'Dosage'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               final updatedReminder = MedicationReminder(
//                 name: nameController.text,
//                 dateTime: dateTimeController.text,
//                 dosage: dosageController.text,
//               );
//               provider.updateMedication(index, updatedReminder);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       );
//     },
//   );
// }

