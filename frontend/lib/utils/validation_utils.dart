import 'package:flutter/material.dart';

String? validateUsername(String? username) {
  if (username == null || username.isEmpty) return 'Username cannot be empty';
  if (!RegExp(r'^[a-zA-Z0-9]{3,}$').hasMatch(username)) {
    return '> Username must be at least 3 characters long and contain only letters and numbers';
  }
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) return 'Password cannot be empty';
  if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$').hasMatch(password)) {
    return '> Password must be at least 8 characters long and contain uppercase, lowercase letter, and a number';
  }
  return null;
}

String? validateEmail(String? email) {
  if (email == null || email.isEmpty) return 'Email cannot be empty';
  if (!RegExp(r'^[\w\.-]+@([\.a-zA-Z0-9]+)+$').hasMatch(email)) {
    return '> Invalid email address';
  }
  return null;
}

void showValidationError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 5),
    ),
  );
}
