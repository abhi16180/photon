import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart' as ulaunch;

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Me'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.email_rounded,
              color: Colors.redAccent,
            ),
            onTap: () {
              var url = Mailto(
                to: ['photon19dev@gmail.com'],
              ).toString();
              ulaunch.launchUrl(Uri.parse(url));
            },
            title: const Text('Email'),
            subtitle: const Text('photon19dev@gmail.com'),
          ),
          ListTile(
            leading: const Icon(UniconsLine.twitter, color: Colors.blueAccent),
            onTap: () {
              ulaunch
                  .launchUrl(Uri.parse('https://twitter.com/AbhilashHegde9'));
            },
            title: const Text('Twitter'),
            subtitle: const Text('https://twitter.com/AbhilashHegde9'),
          )
        ],
      ),
    );
  }
}
