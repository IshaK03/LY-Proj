import 'package:flutter/material.dart';
import 'package:frontend/models/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void addMessage(String message, bool isUser) {
    _messages.add(Message(text: message, isUser: isUser));
    notifyListeners();
  }
}
