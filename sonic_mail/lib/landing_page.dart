import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sonic_mail/user_identifier.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceToUser(); // Announce to the user when the page is fully rendered
    });
  }

  Future<void> _announceToUser() async {
    _isListening = false;
    await flutterTts.speak(
        "Hey, Welcome to Sonic Mail, you can sign into your email account. Say, 'Yes' to continue or tap the screen to repeat again.").then((_) async {
      await Future.delayed(const Duration(seconds: 10));
      _requestMicrophonePermission(); // Call _requestMicrophonePermission() after the announcement
    });
  }

  Future<void> startListening(BuildContext context) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );

      if (available) {
        _isListening = true;
        _speech.listen(
          localeId: 'en-IN',
          onResult: (result) async {
            String command = result.recognizedWords.toLowerCase();
            print('Command: $command');
            if (command.contains('yes')) {
              _isListening = false; // Stop listening
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserIdentifierPage()),
              );
            } else if (command.contains('no')) {
              await flutterTts.speak("Exiting the app").then((_) async {
                await Future.delayed(const Duration(seconds: 2));
                SystemNavigator.pop(); // Close the application
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
      startListening(context); // Start listening for voice commands
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _announceToUser, // Call _announceToUser() whenever the screen is tapped
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/app_logo.png'), // Replace with your logo
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
