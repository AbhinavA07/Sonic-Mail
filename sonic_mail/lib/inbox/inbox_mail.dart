import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonic_mail/google_signin_service.dart';


class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Map<String, dynamic>> _emails = [];

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      final googleSignInService = GoogleSignInService();
      final authData = await googleSignInService.signInAndGetAuthHeaders();
      final String accessToken = authData['accessToken'] ?? '';
      final String userId = authData['userId'] ?? 'me'; // 'me' represents the authenticated user
      print(accessToken);
      print(userId);
      final response = await http.get(
        Uri.https('www.googleapis.com', '/gmail/v1/users/$userId/messages'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> messages = data['messages'];

        // Iterate through each message and fetch its details
        for (var message in messages) {
          final messageId = message['id'];
          final messageResponse = await http.get(
            Uri.https('www.googleapis.com', '/gmail/v1/users/$userId/messages/$messageId'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );
          final messageData = json.decode(messageResponse.body);
          _emails.add(messageData);
        }

        setState(() {});
      } else {
        throw Exception('Failed to fetch emails. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching emails: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: ListView.builder(
        itemCount: _emails.length,
        itemBuilder: (context, index) {
          final email = _emails[index];
          final subject = email['payload']['headers'].firstWhere((header) => header['name'] == 'Subject')['value'];
          final snippet = email['snippet'];
          return ListTile(
            title: Text(subject),
            subtitle: Text(snippet),
          );
        },
      ),
    );
  }
}
