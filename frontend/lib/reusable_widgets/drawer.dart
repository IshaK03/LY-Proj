import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/signin.dart';
import 'package:frontend/utils/getHash.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final userId = user?.uid;

    // Reference to the Firestore user document
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(76, 123, 238, 1),
            ),
            child: FutureBuilder<DocumentSnapshot>(
              future: userDocRef.get(), // Fetch user document
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error fetching user name',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final userName = snapshot.data?.get('name') ?? 'User';
                  return Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  );
                } else {
                  return const Text(
                    'Welcome, User',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
          ListTile(
            title: const Text('Log Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SignIn()));
            },
          ),
          ListTile(
              title: const Text("Patient ID"),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first

                final snapshot = await userDocRef.get();
                final userName = snapshot.data()?['name'] ?? 'User';

                final patientId =
                    generateHash(userName); // <-- call your function

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Your Patient ID'),
                      content: Text(
                        patientId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              })
        ],
      ),
    );
  }
}
