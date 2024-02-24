import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sonic_mail/home_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

bool _isListening = false;
stt.SpeechToText _speech = stt.SpeechToText();
FlutterTts flutterTts = FlutterTts();
GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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
            _signInWithGoogle(context);
          }
          else if(command.contains('no')){
            await flutterTts.speak("Exiting the app").then((_) async {
              await Future.delayed(const Duration(seconds: 2));
              SystemNavigator.pop(); // Close the application
            });
          }
          else{
            startListening(context);
          }
        },
        localeId: 'en-IN',
      );
    }
  }
}

Future<void> _signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
    if (googleUser != null) {
      await flutterTts.speak("Signing you in ${googleUser.displayName}").then((_) async {
        await Future.delayed(const Duration(seconds:3));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to HomeScreen
        );
      });
    } else {
      // User not signed in silently, attempt normal sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        await flutterTts.speak("Signing you in ${googleUser.displayName}").then((_) async {
          await Future.delayed(const Duration(seconds: 3));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to HomeScreen
          );
        });
      } else {
        // User canceled the sign-in process
        print('Sign-in canceled');
      }
    }
  } catch (error) {
    print('Error signing in: $error');
    // Handle sign-in error
  }
}