import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SignInHelper {
  static const bool _isListening = false;
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static FlutterTts flutterTts = FlutterTts();

  static Future<void> startListening(BuildContext context) async {
    // Your logic to start listening for voice commands
  }

  static Future<void> signIn(BuildContext context) async {
    // Your logic to sign in with Enough Mail
  }
}
