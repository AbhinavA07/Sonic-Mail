import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({Key? key}) : super(key: key);

  @override
  _ComposeScreenState createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  Future<void> _sendEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email') ?? '';
      final String password = prefs.getString('password') ?? '';

      final client = SmtpClient('smtp.gmail.com', isLogEnabled: true, onBadCertificate: (cert) => true);
      await client.connectToServer('smtp.gmail.com', 587,
          isSecure: false, timeout: const Duration(seconds: 30));
      await client.ehlo();

      await client.startTls();
      await client.authenticate(email, password);

      MimeMessage buildMessage() {
        final builder = MessageBuilder.prepareMultipartAlternativeMessage(
          plainText: _bodyController.text,
          htmlText: '<p>${_bodyController.text}</p>',
        )
          ..from = [MailAddress('TVE22MCA', email)]
          ..to = [MailAddress('', _recipientController.text)]
          ..subject = _subjectController.text;

        return builder.buildMimeMessage();
      }

      final sendResult = await client.sendMessage(buildMessage());
      print('Send result: $sendResult');

      await client.disconnect();
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(labelText: 'Recipient'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextFormField(
                controller: _bodyController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
            ),
            ElevatedButton(
              onPressed: _sendEmail,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
