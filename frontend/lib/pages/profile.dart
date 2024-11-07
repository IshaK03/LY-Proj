import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _emergencyContactsController =
      TextEditingController();

  String? _selectedRole =
      'Patient'; // Default role (this will be autofilled from Firestore)
  String? _nameError;
  String? _bloodGroupError;
  String? _allergiesError;
  String? _emergencyContactsError;

  late String _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile data from Firestore
  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        // Pre-fill existing fields (name, role)
        _nameController.text = data['name'] ?? '';
        _selectedRole =
            data['role'] ?? 'Patient'; // Set the role (Patient/Guardian)

        // New fields (bloodGroup, allergies, emergencyContacts) will be empty initially
        _bloodGroupController.text = data['bloodGroup'] ?? '';
        _allergiesController.text = data['allergies'] ?? '';
        _emergencyContactsController.text =
            data['emergencyContacts']?.join(", ") ?? '';
      }
    }
  }

  // Save the updated profile data to Firestore
  Future<void> _saveProfile() async {
    try {
      // Convert emergency contacts string to list of phone numbers
      List<String> emergencyContacts = _emergencyContactsController.text
          .split(',')
          .map((e) => e.trim())
          .toList();

      // Update Firestore with the new fields
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': _nameController.text,
        'role': _selectedRole,
        'bloodGroup': _bloodGroupController.text,
        'allergies': _allergiesController.text,
        'emergencyContacts': emergencyContacts,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Validate the fields
  void validateFields() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? "Name can't be empty" : null;
      _bloodGroupError = _bloodGroupController.text.isEmpty
          ? "Blood group can't be empty"
          : null;
      _allergiesError =
          _allergiesController.text.isEmpty ? "Allergies can't be empty" : null;
      _emergencyContactsError = _emergencyContactsController.text.isEmpty
          ? "Emergency contacts can't be empty"
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Color.fromRGBO(76, 123, 238, 1),
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Name field (editable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter Name",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Colors.white70),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      errorText: _nameError,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Role selection (editable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(31.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Select Role',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 17.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          value: "Patient",
                          groupValue: _selectedRole,
                          title: Text(
                            'Patient',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                          activeColor: Colors.white70,
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          value: "Guardian",
                          groupValue: _selectedRole,
                          title: Text(
                            'Guardian',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                          activeColor: Colors.white70,
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 4),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Blood Group field (editable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _bloodGroupController.text.isEmpty
                        ? null
                        : _bloodGroupController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _bloodGroupController.text = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Enter Blood Group",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      prefixIcon:
                          const Icon(Icons.bloodtype, color: Colors.white70),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded borders
                        borderSide:
                            const BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      errorText: _bloodGroupError,
                    ),
                    style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.9)), // Text color in the dropdown
                    iconEnabledColor: Colors.white, // Icon color in the button

                    // Items list (blood groups)
                    items: [
                      'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              color: Colors
                                  .black), // Text color for the dropdown items
                        ),
                      );
                    }).toList(),

                    // Dropdown menu customization
                    dropdownColor:
                        Colors.blueAccent, // Background color of the dropdown
                    menuMaxHeight:
                        200, // Set a max height for the dropdown menu
                    isExpanded:
                        true, // Ensures the dropdown button and menu width matches
                    // Dropdown is constrained to prevent it from opening upwards:
                    alignment: Alignment.centerLeft,
                    selectedItemBuilder: (BuildContext context) {
                      return [
                        'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
                      ].map<Widget>((String item) {
                        return Text(
                          item,
                          style: TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Allergies field (editable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _allergiesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter Allergies",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      prefixIcon: const Icon(Icons.local_hospital,
                          color: Colors.white70),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      errorText: _allergiesError,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Emergency Contacts field (editable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _emergencyContactsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter Emergency Contacts (Eg: +91XXXXXXXXXX, +91XXXXXXXXXX)",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      prefixIcon:
                          const Icon(Icons.phone, color: Colors.white70),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      errorText: _emergencyContactsError,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        validateFields();
                        if (_nameError == null &&
                            _bloodGroupError == null &&
                            _allergiesError == null &&
                            _emergencyContactsError == null) {
                          _saveProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
