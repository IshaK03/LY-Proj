import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/reusable_widgets/reusable_widgets.dart';
import 'package:frontend/utils/validation_utils.dart';
import 'dart:async'; // Import to use Timer for periodic checks

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  String? _selectedRole = 'Patient'; // Default role

  bool _isLinkSent = false; // Track if verification link was sent
  bool _isEmailVerified = false;
  Timer? _timer; // To periodically check for email verification

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  // Start the periodic email verification check
  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkEmailVerified();
    });
  }

  // Stop the periodic check when the widget is disposed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Check if email is verified
  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Refresh the user data
      setState(() {
        _isEmailVerified = user.emailVerified;
      });

      // If the email is verified, navigate to the HomeScreen
      if (_isEmailVerified) {
        _timer?.cancel(); // Stop the timer since email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  void validateFields() {
    setState(() {
      _usernameError = validateUsername(_userNameTextController.text);
      _emailError = validateEmail(_emailTextController.text);
      _passwordError = validatePassword(_passwordTextController.text);

      if (_usernameError != null ||
          _emailError != null ||
          _passwordError != null) {
        String errorMessage = '';
        if (_usernameError != null) errorMessage += _usernameError!;
        if (_emailError != null) errorMessage += '\n${_emailError!}';
        if (_passwordError != null) errorMessage += '\n${_passwordError!}';

        showValidationError(context, errorMessage);
      }
    });
  }

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      setState(() {
        _isLinkSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Verification link sent! Check your email."),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      showValidationError(context, "Error sending verification link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                reusableTextField("Enter Username", Icons.person_outline, false,
                    _userNameTextController, validateUsername),
                const SizedBox(height: 20),
                reusableTextField("Enter Email-Id", Icons.email, false,
                    _emailTextController, validateEmail),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController, validatePassword),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(31.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Aligns the title and radio buttons to the left
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,18,0,0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline, // Add the icon here
                              color: Colors.white70,
                            ),
                            const SizedBox(
                                width: 8.0), // Space between icon and text
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
                const SizedBox(height: 20),
                signInSignUpButton(context, false, () async {
                  validateFields();
                  if (_usernameError == null &&
                      _emailError == null &&
                      _passwordError == null) {
                    try {
                      // Create the user
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text,
                      );

                      User user = userCredential.user!;
                      await _sendVerificationEmail(
                          user); // Send the verification email
                    } catch (error) {
                      showValidationError(
                          context, "Sign up failed: ${error.toString()}");
                    }
                  }
                }),
                const SizedBox(height: 20),
                // Resend Link Button (only appears if the link has been sent)
                _isLinkSent
                    ? ElevatedButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await _sendVerificationEmail(user);
                          }
                        },
                        child: const Text('Resend Verification Link'),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
