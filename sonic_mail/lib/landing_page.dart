import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sonic_mail/voice_recognition.dart';
import 'package:flutter/services.dart'; // Import the SystemNavigator class

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  FlutterTts flutterTts = FlutterTts();
  bool _isMicrophonePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceToUser(); // Announce to the user when the page is fully rendered
    });
  }

  Future<void> _announceToUser() async {
    await flutterTts.speak(
        "Hey, you can sign into your Gmail account. Say 'Yes' to continue or tap the screen to dismiss.").then((_) async {
      await Future.delayed(const Duration(seconds: 7));
      _requestMicrophonePermission(); // Call _requestMicrophonePermission() after the announcement
    });

  }


  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      _isMicrophonePermissionGranted = true;
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
