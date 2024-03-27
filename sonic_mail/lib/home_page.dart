import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonic_mail/mail/compose_mail.dart';
import 'package:sonic_mail/mail/inbox_mail.dart';
import 'package:sonic_mail/mail/sent_mail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'mail/trash_mail.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>{
  FlutterTts flutterTts = FlutterTts();
  bool _isListeningHome = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceToUserHome();
    });
  }

  Future<void> _announceToUserHome() async{
    _isListeningHome = false;
    await flutterTts.speak(
        "What can I do for you? You can say compose, inbox, sent, trash, or exit the app.").then((_) async {
    await Future.delayed(const Duration(seconds: 6));
    _requestMicrophonePermission();
    });
  }

  Future<void> startListeningHome(BuildContext context) async {
    if(!_isListeningHome){
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );

      if (available) {
        _isListeningHome = true;
        _speech.listen(
          localeId: 'en-IN',
          onResult: (result) async {
            String command = result.recognizedWords.toLowerCase();
            print('Command: $command');
            if (command.contains('compose')) {
              _isListeningHome = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComposeScreen()),
              );
            } else if (command.contains('inbox')) {
              _isListeningHome = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxScreen()),
              );
            } else if (command.contains('sent')) {
              _isListeningHome = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SentMailPage()),
              );
            } else if (command.contains('trash')) {
              _isListeningHome = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrashScreen()),
              );
            } else if (command.contains('exit')) {
              await flutterTts.speak("Exiting the app").then((_) async {
                await Future.delayed(const Duration(seconds: 2));
                SystemNavigator.pop();
              });
            }
          },
        );
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      startListeningHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _announceToUserHome,
      child: Scaffold(
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
                onPressed: () {},
                child: const Text('Compose'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Inbox'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Sent'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Trash'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Exit App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}