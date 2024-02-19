import 'package:flutter/material.dart';

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
              child: const Text('Read Unread Messages'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to screen to search for email
              },
              child: const Text('Search for Email'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Exit the app
                Navigator.pop(context);
              },
              child: const Text('Exit App'),
            ),
          ],
        ),
      ),
    );
  }
}
