import 'package:flutter/material.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/reusable_widgets/reusable_widgets.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
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
        )),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Username", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email-Id", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                })
                // firebaseUIButton(context, "Sign Up", () {
                //   FirebaseAuth.instance
                //       .createUserWithEmailAndPassword(
                //           email: _emailTextController.text,
                //           password: _passwordTextController.text)
                //       .then((value) {
                //     print("Created New Account");
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => HomeScreen()));
                //   }).onError((error, stackTrace) {
                //     print("Error ${error.toString()}");
                //   });
                // })
              ],
            ),
          ))),
    );
  }
}
