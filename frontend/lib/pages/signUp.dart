// signUp.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/reusable_widgets/reusable_widgets.dart';
import 'package:frontend/utils/validation_utils.dart';

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

  void validateFields() {
    setState(() {
      _usernameError = validateUsername(_userNameTextController.text);
      _emailError = validateEmail(_emailTextController.text);
      _passwordError = validatePassword(_passwordTextController.text);

      if (_usernameError != null || _emailError != null || _passwordError != null) {
        String errorMessage = '';
        if (_usernameError != null) errorMessage += _usernameError!;
        if (_emailError != null) errorMessage += '\n${_emailError!}';
        if (_passwordError != null) errorMessage += '\n${_passwordError!}';

        showValidationError(context, errorMessage);
      }
    });
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
                reusableTextField("Enter Username", Icons.person_outline, false, _userNameTextController, validateUsername),
                const SizedBox(height: 20),
                reusableTextField("Enter Email-Id", Icons.email, false, _emailTextController, validateEmail),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outlined, true, _passwordTextController, validatePassword),
                const SizedBox(height: 20),
                signInSignUpButton(context, false, () {
                  validateFields();
                  if (_usernameError == null && _emailError == null && _passwordError == null) {
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    ).then((value) {
                      print("----------------------------->>>>>>>> Account Created Successfully");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
