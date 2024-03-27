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
      _announceToUser();
    });
  }

  Future<void> _announceToUser() async {
    _isListening = false;
    await flutterTts.speak(
        "Hey, Welcome to Sonic Mail, you can sign into your email account. Say, 'Yes' to continue or tap the screen to repeat again.").then((_) async {
      await Future.delayed(const Duration(seconds: 10));
      _requestMicrophonePermission();
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
              _isListening = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserIdentifierPage()),
              );
            } else if (command.contains('no')) {
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
      startListening(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _announceToUser,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/app_logo.png'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
