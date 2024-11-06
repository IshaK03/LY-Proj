import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

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
}
