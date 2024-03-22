import 'package:chat_bot_gemini/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import '../model/message.dart';
import 'widget/messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages
          .add(Message(message: message, isUser: true, date: DateTime.now()));
    });

    //! send message to chatbot and wait respone
    final content = [Content.text(message)];
    final respone = await model.generateContent(content);
    setState(() {
      _messages.add(Message(
          message: respone.text ?? "", isUser: false, date: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gemini Chat Bot"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Messages(
                isUser: message.isUser,
                message: message.message,
                date: DateFormat('HH:mm').format(message.date),
              );
            },
          )),

          //! Chat Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: TextFormField(
                    controller: _userMessage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text("Enter your message"),
                    ),
                  ),
                ),
                const Spacer(),

                //! Send Button
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  padding: const EdgeInsets.all(15),
                  iconSize: 30,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF9575CD)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(const CircleBorder())),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
