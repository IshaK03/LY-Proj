import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class ApiService {
  // Add your laptop IP address
  final String baseUrl = "http://192.168.0.208:8000";

  Future<String> sendQuery(String userMessage) async {
    final url = Uri.parse("$baseUrl/run_query/");

    try {
      Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']; // Returns the chatbot's response text
      } else {
        return "Error: Server returned status code ${response.statusCode}";
      }
    } catch (e) {
      return "Error: Failed to connect to server";
    }
  }

  Future<String> getMedicationReminders(File image) async {
    final url = Uri.parse("$baseUrl/upload_image/");

    try {
      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Success";
      } else {
        return "Error: Server returned status code ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
      return "Error: Failed to connect to server";
    }
  }

  Future<void> sendEmergencyNotification(
      String guardianFcmToken, String userName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-notification/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'device_token': guardianFcmToken,
          'title': 'Emergency Alert!',
          'body': '$userName is in need of assistance.', // Include user name
          'data': {
            'click_action':
                'FLUTTER_NOTIFICATION_CLICK', // Required for Flutter to handle the notification
            'status': 'emergency', // Custom data to indicate emergency
            'userName': userName, //send user name.
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully!');
      } else {
        debugPrint(
            'Failed to send notification. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}'); // Add this line
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      throw Exception('Error sending notification: $e'); // Re-throw the error
    }
  }
}
