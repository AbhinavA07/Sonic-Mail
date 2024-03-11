import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<MimeMessage> _emails = [];

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email') ?? '';
      final String password = prefs.getString('password') ?? '';

      final client = ImapClient(isLogEnabled: true);
      await client.connectToServer('imap.gmail.com', 993);
      await client.login(email, password);

      final mailboxes = await client.listMailboxes();
      final inbox = mailboxes.firstWhere((mailbox) => mailbox.name == 'INBOX');
      await client.selectMailbox(inbox);

      final fetchResult = await client.fetchRecentMessages(
        messageCount: 20,
        criteria: 'ALL',
      );

      setState(() {
        _emails = fetchResult.messages;
      });

      await client.logout();
      await client.disconnect();
    } catch (e) {
      print('Error fetching emails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: ListView.builder(
        itemCount: _emails.length,
        itemBuilder: (context, index) {
          final email = _emails[index];
          return ListTile(
            title: Text(email.decodeSubject() ?? 'No Subject'),
            subtitle: Text(email.from?.first.mailboxName ?? 'No Sender'),
          );
        },
      ),
    );
  }
}
