import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SentMailPage extends StatefulWidget {
  const SentMailPage({Key? key}) : super(key: key);

  @override
  _SentMailPageState createState() => _SentMailPageState();
}

class _SentMailPageState extends State<SentMailPage> {
  List<MimeMessage> _sentMails = [];

  Future<void> _fetchSentMails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email') ?? '';
      final String password = prefs.getString('password') ?? '';

      final client = ImapClient(isLogEnabled: true);
      await client.connectToServer('imap.gmail.com', 993, isSecure: true);
      await client.login(email, password);

      final mailboxes = await client.listMailboxes();
      final sentMailbox = mailboxes.firstWhere((mailbox) => mailbox.name == 'Sent');
      await client.selectMailbox(sentMailbox);

      final fetchResult = await client.fetchRecentMessages(
        messageCount: 20,
        criteria: 'ALL',
      );

      setState(() {
        _sentMails = fetchResult.messages;
      });

      await client.logout();
      await client.disconnect();
    } catch (e) {
      print('Error fetching sent mails: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSentMails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent Mail'),
      ),
      body: ListView.builder(
        itemCount: _sentMails.length,
        itemBuilder: (context, index) {
          final sentMail = _sentMails[index];
          return ListTile(
            title: Text(sentMail.decodeSubject() ?? 'No Subject'),
            subtitle: Text(sentMail.from?.first.mailboxName ?? 'No Sender'),
          );
        },
      ),
    );
  }
}
