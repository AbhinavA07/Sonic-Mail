import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sonic_mail/inbox/inbox_mail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

bool _isListening = false;
stt.SpeechToText _speech = stt.SpeechToText();
FlutterTts flutterTts = FlutterTts();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What can I do for you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to screen to read unread messages
              },
              child: const Text('Compose'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InboxScreen()),
                );
              },
              child: const Text('Inbox'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to screen to search for email
              },
              child: const Text('Sent'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to screen to search for email
              },
              child: const Text('Trash'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await flutterTts.speak("Exiting the app").then((_) async {
                  await Future.delayed(const Duration(seconds: 3));
                  SystemNavigator.pop(); // Close the application
                });
              },
              child: const Text('Exit App'),
            ),
          ],
        ),
      ),
    );
  }
}

void startListening(BuildContext context) async {
  if (!_isListening) {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );

    if (available) {
      _isListening = false;
      _speech.listen(
        onResult: (result) async {
          String command = result.recognizedWords.toLowerCase();
          print('Command: $command');
          if (command.contains('compose')) {

          }
          else if(command.contains('inbox')){

          }
          else if(command.contains('sent')){

          }
          else if(command.contains('trash')){

          }
          else if(command.contains('exit')){

          }
          else{

          }
        },
        localeId: 'en-IN',
      );
    }
  }
}