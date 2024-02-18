import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

bool _isListening = false;
stt.SpeechToText _speech = stt.SpeechToText();
FlutterTts flutterTts = FlutterTts();

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
          if (command.contains('yes')) {
            // Perform sign in with Google action
            // For now, just print a message
            print('Signing in with Google...');
            Navigator.pushReplacementNamed(context, '/signInWithGoogle'); // Navigate to sign in page
          }
          else if(command.contains('no')){
            await flutterTts.speak("Exiting the app").then((_) async {
              await Future.delayed(const Duration(seconds: 3));
              SystemNavigator.pop(); // Close the application
            });
          }
          else{
            startListening(context);
          }
        },
      );
    }
  }
}

