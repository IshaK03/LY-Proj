import 'package:flutter/material.dart';
import 'package:frontend/providers/chatprovider.dart';
import 'package:frontend/reusable_widgets/bottomNavbar.dart';
import 'package:frontend/reusable_widgets/drawer.dart';
import 'package:frontend/utils/api_service.dart';
import 'package:provider/provider.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final TextEditingController _controller = TextEditingController();
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  void sendMessage(BuildContext context, String message) {
    if (message.trim().isEmpty) return;

    // Call sendMessageToServer, which sends the message to FastAPI and updates the UI with the response
    context.read<ChatProvider>().sendMessageToServer(message);

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
      drawer: const CustomDrawer(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4b6cb7), Color(0xff182848)],
            stops: [0, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                      margin: EdgeInsets.symmetric(vertical: 7.0),
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
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 85),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(height: 1.5, color: Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }
}
