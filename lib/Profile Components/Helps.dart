import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<ChatMessage> chatMessages = [
    ChatMessage(isUser: false, text: "Hello! How can I help you?"),
  ];

  HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        centerTitle: true,
        elevation: 10,
        backgroundColor: const Color.fromARGB(255, 6, 60, 74),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 80, 101),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            TextField(
              onSubmitted: (text) {
                final response = getResponse(text);
                addMessage(response!);
              },
              decoration: InputDecoration(
                hintText: 'Type your question...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final response = getResponse();
                    addMessage(response!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? getResponse([String? userQuery]) {
    final responses = {
      "signup":
          "To sign up, go to the sign-up page and fill out the required information.",
      "login": "To log in, visit the login page and enter your credentials.",
      "forgot password":
          "If you forgot your password, you can reset it on the forgot password page.",
      "default":
          "I'm sorry, I don't understand your question. Please ask another question or contact support.",
    };

    final query = userQuery?.toLowerCase() ?? '';
    return responses.containsKey(query)
        ? responses[query]
        : responses["default"];
  }

  void addMessage(String text, {bool isUser = true}) {
    final message = ChatMessage(isUser: isUser, text: text);
    chatMessages.add(message);
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage({required this.isUser, required this.text});
}
