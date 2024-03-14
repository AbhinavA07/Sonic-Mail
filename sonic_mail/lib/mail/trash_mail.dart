import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<MimeMessage> _trashEmails = [];

  @override
  void initState() {
    super.initState();
    _fetchTrashEmails();
  }

  Future<void> _fetchTrashEmails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email') ?? '';
      final String password = prefs.getString('password') ?? '';

      final client = ImapClient(isLogEnabled: true);
      await client.connectToServer('imap.gmail.com', 993);
      await client.login(email, password);

      final mailboxes = await client.listMailboxes(path: ''"[Gmail]/Bin"'');
      final trashMailbox = mailboxes.firstWhere((mailbox) => mailbox.name == "Bin");
      await client.selectMailbox(trashMailbox);

      final fetchResult = await client.fetchRecentMessages(
        messageCount: 20,
        criteria: 'ALL',
      );

      setState(() {
        _trashEmails = fetchResult.messages;
      });

      await client.logout();
      await client.disconnect();
    } catch (e) {
      print('Error fetching trash emails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      body: ListView.builder(
        itemCount: _trashEmails.length,
        itemBuilder: (context, index) {
          final email = _trashEmails[index];
          return ListTile(
            title: Text(email.decodeSubject() ?? 'No Subject'),
            subtitle: Text(email.from?.first.personalName ?? 'No Sender'),
          );
        },
      ),
    );
  }
}
