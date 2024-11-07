import 'package:flutter/material.dart';
import 'package:frontend/models/medication_reminder.dart';

class MedicationProvider extends ChangeNotifier {
  final List<MedicationReminder> _medications = [];

  List<MedicationReminder> get medications => _medications;

  void addMedication(MedicationReminder reminder) {
    _medications.add(reminder);
    notifyListeners();
  }

  void removeMedication(MedicationReminder reminder) {
    _medications.remove(reminder);
    notifyListeners();
  }

  void updateMedication(int index, MedicationReminder newReminder) {
    _medications[index] = newReminder;
    notifyListeners();
  }
}
