import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/medication_reminder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationProvider with ChangeNotifier {
  List<MedicationReminder> _medicationReminders = [];

  List<MedicationReminder> get medicationReminders => _medicationReminders;

  final CollectionReference _remindersRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('medicationReminders');

  Future<void> fetchReminders() async {
    try {
      final querySnapshot = await _remindersRef.get();
      _medicationReminders = querySnapshot.docs.map((doc) {
        return MedicationReminder.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      notifyListeners();
    } catch (error) {
      print('Error fetching reminders: $error');
    }
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    try {
      // Let Firestore generate the ID and create the document
      final docRef = await _remindersRef.add(reminder.toJson());
      // Firestore generates the ID and we update the local object with that ID
      final newReminder =
          MedicationReminder.fromJson(reminder.toJson(), docRef.id);

      // Add the new reminder with the generated ID
      _medicationReminders.add(newReminder);
      notifyListeners();
    } catch (error) {
      print('Error adding reminder: $error');
    }
  }

  Future<void> editMedication(MedicationReminder editedReminder) async {
    try {
      // Update the Firestore document
      await _remindersRef
          .doc(editedReminder.id)
          .update(editedReminder.toJson());

      // Update the local list of reminders
      int index = _medicationReminders
          .indexWhere((reminder) => reminder.id == editedReminder.id);
      if (index != -1) {
        _medicationReminders[index] =
            editedReminder; // Replace with the updated reminder
        notifyListeners();
      }
    } catch (error) {
      print('Error editing reminder: $error');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _remindersRef.doc(reminderId).delete();
      _medicationReminders.removeWhere((reminder) => reminder.id == reminderId);
      notifyListeners();
    } catch (error) {
      print('Error deleting reminder: $error');
    }
  }

  Future<void> fetchRemindersFromEndpoint(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        for (var reminderData in jsonResponse) {
          MedicationReminder reminder =
              MedicationReminder.fromJson(reminderData, reminderData['id']);

          // Check if the reminder already exists in Firestore
          bool exists = await _remindersRef
              .doc(reminder.id)
              .get()
              .then((doc) => doc.exists);

          if (!exists) {
            await _remindersRef.doc(reminder.id).set(reminder.toJson());
            _medicationReminders.add(reminder);
          }
        }

        notifyListeners();
      } else {
        print('Failed to fetch reminders: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reminders from API: $error');
    }
  }
}
