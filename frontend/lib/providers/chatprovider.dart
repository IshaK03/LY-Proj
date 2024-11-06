import 'package:flutter/material.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/utils/api_service.dart'; // Make sure this path matches your project structure

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  List<Message> get messages => _messages;

  void addMessage(String message, bool isUser) {
    _messages.add(Message(text: message, isUser: isUser));
    notifyListeners();
  }

  // Function to handle sending a message to the FastAPI server
  Future<void> sendMessageToServer(String userMessage) async {
    // Add the user's message to the chat
    addMessage(userMessage, true);

    // Send the user's message to the FastAPI server and wait for the response
    final botResponse = await apiService.sendQuery(userMessage);

    // Add the bot's response to the chat
    addMessage(botResponse, false);
  }
}
