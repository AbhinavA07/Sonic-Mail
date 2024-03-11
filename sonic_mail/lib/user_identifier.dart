import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class UserIdentifierPage extends StatefulWidget {
  const UserIdentifierPage({super.key});

  @override
  _UserIdentifierPageState createState() => _UserIdentifierPageState();
}

class _UserIdentifierPageState extends State<UserIdentifierPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Identification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Your Username and Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEmailAndPassword,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmailAndPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = _emailController.text;
    final String password = _passwordController.text;
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    // Optionally, you can navigate to the next screen or perform other actions here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
