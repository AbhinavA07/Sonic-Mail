import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonic_mail/home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  FlutterTts flutterTts = FlutterTts();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceToUser(); // Announce to the user when the page is fully rendered
    });
  }

  Future<void> _announceToUser() async {
    await flutterTts.speak(
        "Hey, Welcome to Sonic Mail, you can sign into your email account. Say, 'Yes' to continue or tap the screen to repeat again.").then((_) async {
      await Future.delayed(const Duration(seconds: 10));
      _requestMicrophonePermission(); // Call _requestMicrophonePermission() after the announcement
    });
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      startListening(context); // Start listening for voice commands
    }
  }

  Future<void> _saveEmailAndPassword(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveEmailAndPassword(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
