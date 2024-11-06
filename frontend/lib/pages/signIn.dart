import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/chatpage.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/signUp.dart';
import 'package:frontend/reusable_widgets/bottomNavbar.dart';
import 'package:frontend/reusable_widgets/reusable_widgets.dart';
import 'package:frontend/utils/validation_utils.dart'; // Add this import

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  void validateFields() {
    setState(() {
      _emailError = validateEmail(_emailTextController.text);
      _passwordError = validatePassword(_passwordTextController.text);

      if (_emailError != null || _passwordError != null) {
        String errorMessage = '';
        if (_emailError != null) errorMessage += _emailError!;
        if (_passwordError != null) errorMessage += '\n${_passwordError!}';

        showValidationError(context, errorMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.15, 20, 0),
            child: Column(
              children: [
                logoWidget("assets/images/logo.png"),
                const SizedBox(height: 30),
                reusableTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController, validateEmail),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController, validatePassword),
                const SizedBox(height: 10),
                signInSignUpButton(context, true, () {
                  validateFields();
                  if (_emailError == null && _passwordError == null) {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((value) {
                      print("****************************LOGGED IN");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavbar()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  }
                }),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUp()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
