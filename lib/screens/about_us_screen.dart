import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  static const String id = 'about_us_screen';

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(child: Text('About us')),
          backgroundColor: Colors.lightBlueAccent,
          actions: [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.all(15.0),
          child: Text(
            'Hi there dear user.\nI\'m Omar Mohamed, the developer of this application "⚡ Chat".\n'
            'I\'m a Cairo University - Faculty of Engineering student, Computer Engineering major to be more specific.\n'
            'I\'ve started this application with Angela Yu\'s  Android Development Course.\n'
            'This is a group chat application called "Flash Chat" which allows its users to contact with each other.\n'
            'I\'ve developed the application Firebase to make it better!\n'
            'I\'ve stored the message time to view the messages in the right order because I found it will be better.\n'
            'As I\'ve wanted to print the message time under every message to the user.\n'
            'I hope that you\'ll find our application meets your expectations.\n'
            'Enjoy!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.black,
              height: 2,
            ),
          ),
        ),
      ),
    );
  }
}
