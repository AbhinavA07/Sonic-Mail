import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<MimeMessage> _emails = [];
  int _selectedEmailIndex = -1;
  final FlutterTts flutterTts = FlutterTts();

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
        // messageCount: 20,
        criteria: 'BODY.PEEK[]',
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

  Future<void> _speakEmail(MimeMessage email) async {
    await flutterTts.speak('Subject: ${email.decodeSubject()}\nFrom: ${email.from?.first.personalName}');
  }

  void _selectEmail(int index) {
    setState(() {
      _selectedEmailIndex = index;
    });
  }

  void _navigateToEmailContent() {
    if (_selectedEmailIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailContentScreen(email: _emails[_selectedEmailIndex]),
        ),
      );
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
            subtitle: Text(email.from?.first.personalName ?? 'No Sender'),
            selected: _selectedEmailIndex == index,
            onTap: () {
              _selectEmail(index);
              _speakEmail(email);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEmailContent,
        child: const Icon(Icons.read_more),
      ),
    );
  }
}

class EmailContentScreen extends StatelessWidget {
  final MimeMessage email;
  final FlutterTts flutterTts = FlutterTts();
  EmailContentScreen({Key? key, required this.email}) : super(key: key) {
    _speakEmailContent();
  }

  String? _parseEmailContent(MimeMessage email) {
    final decodedText = email.decodeTextPlainPart();
    final cleanedText = decodedText?.replaceAllMapped(
      RegExp(r'^.*?\n|<https?://\S+>|\[.*?\]|\b\d{3}\d{3}\d{4}\b|\*', caseSensitive: false, dotAll: true),
          (match) {
        if (match.group(0)!.startsWith(r'<')) {
          return '';
        } else if (match.group(0)!.startsWith('[')) {
          return '';
        } else if (match.group(0)!.endsWith('*')) {
          return match.group(0)!.substring(0, match.group(0)!.length - 1);
        } else {
          return match.group(0)!.replaceAllMapped(RegExp(r'\d'), (match) => '${match.group(0)} ')
              .trim();
        }
      },
    ).replaceAll(RegExp(r'(\r\n|\n|\r)'), " ");
    return cleanedText;
  }

  Future<void> _speakEmailContent() async {
    String? emailContent = _parseEmailContent(email);
    await flutterTts.speak(emailContent!);
  }

  @override
  Widget build(BuildContext context) {
    String? emailContent = _parseEmailContent(email);
    return Scaffold(
      appBar: AppBar(
        title: Text(email.decodeSubject() ?? 'No Subject'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${email.from?.first.personalName ?? 'No Sender'}'),
              Text('To: ${email.to?.first.personalName ?? 'Unknown Recipient'}'),
              const SizedBox(height: 20),
              Text(emailContent!),
            ],
          ),
        ),
      ),
    );
  }
}
