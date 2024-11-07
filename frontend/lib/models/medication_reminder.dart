class MedicationReminder {
  final String id;
  final String name;
  final DateTime dateTime; // Change to DateTime type
  final String dosage;
  bool isNotified;

  MedicationReminder({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.dosage,
    this.isNotified = false,
  });

  // Convert to JSON for Firestore, excluding the ID
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(), // Convert DateTime to string for Firestore
      'dosage': dosage,
      'isNotified': isNotified,
    };
  }

  // Create a MedicationReminder from JSON and assign an ID
  factory MedicationReminder.fromJson(Map<String, dynamic> json, String id) {
    return MedicationReminder(
      id: id,
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime']), // Convert string to DateTime
      dosage: json['dosage'],
      isNotified: json['isNotified'] ?? false,
    );
  }
}
