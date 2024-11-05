import 'package:flutter/material.dart';
import 'package:frontend/providers/chatprovider.dart';
import 'package:provider/provider.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final TextEditingController _controller = TextEditingController();
  void sendMessage(BuildContext context, String message) {
    if (message.trim().isEmpty) return;

    context.read<ChatProvider>().addMessage(message, true);

    Future.delayed(Duration(seconds: 1), () {
      context.read<ChatProvider>().addMessage("Bot said: $message", false);
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot UI'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(76, 123, 238, 1),
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(76, 123, 238, 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: EdgeInsets.all(10.0),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message =
                      chatProvider.messages.reversed.toList()[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color.fromRGBO(0, 38, 153, 1)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                            height: 2,
                            color:
                                message.isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(height: 2.0, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 119, 138, 181),
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () => sendMessage(context, _controller.text),
                        icon: const Icon(Icons.send)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
