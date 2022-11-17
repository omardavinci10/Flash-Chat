import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  String messageTime;
  String messageDate;

  Icon lightIcon = Icon(
    Icons.radio_button_off,
    color: Colors.white,
  );
  Icon darkIcon = Icon(
    Icons.lens,
    color: Colors.blueGrey,
  );

  Color myBackgroundColor;
  Icon myIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    myBackgroundColor = lightIcon.color;
    myIcon = darkIcon;
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      Alert(
        context: context,
        style: alertStyle,
        type: AlertType.info,
        title: "User error",
        desc:
            "Either you\'ve been signed out or error in connection occurred, try re-logging.",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: myBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: myIcon,
              onPressed: () {
                setState(() {
                  myBackgroundColor = myBackgroundColor == lightIcon.color
                      ? darkIcon.color
                      : lightIcon.color;
                  myIcon = myIcon == lightIcon ? darkIcon : lightIcon;
                });
              },
            ),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  //Implement logout functionality
                  _auth.signOut();
                  Navigator.pop(context);
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        //Implement send functionality.
                        var currTime = DateTime.now();
                        print(currTime);
                        messageTime = DateFormat.Hms().format(currTime);
                        messageDate = DateFormat('yyyy/MM/dd').format(currTime);
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'time': messageTime,
                          'date': messageDate,
                          'senderEmail': loggedInUser.email,
                          'senderDisplayName': loggedInUser.displayName,
                        });
                        messageTextController.clear();
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageTime = message['time'];
          final messageDate = message['date'];
          final messageSenderEmail = message['senderEmail'];
          final messageSenderDisplayName = message['senderDisplayName'];
          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            time: messageTime,
            date: messageDate,
            text: messageText,
            senderDisplayName: messageSenderDisplayName,
            isMe: currentUser == messageSenderEmail,
          );
          messageBubbles.add(messageBubble);
        }
        messageBubbles.sort((a, b) => a.compareTo(b.time, b.date));
        messageBubbles = List.from(messageBubbles.reversed);
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String senderDisplayName;
  final String text;
  final String time;
  final String date;
  final bool isMe;

  MessageBubble(
      {this.text, this.time, this.date, this.senderDisplayName, this.isMe});

  int compareTo(String bTime, String bDate) {
    List<int> myTime = time.split(':').map(int.parse).toList();
    List<int> passedTime = bTime.split(':').map(int.parse).toList();
    List<int> myDate = date.split('/').map(int.parse).toList();
    List<int> passedDate = bDate.split('/').map(int.parse).toList();

    if (myDate[0] == passedDate[0]) {
      //same year
      if (myDate[1] == passedDate[1]) {
        //same month
        if (myDate[2] == passedDate[2]) {
          //same day
          if (myTime[0] == passedTime[0]) {
            //same hour
            if (myTime[1] == passedTime[1]) {
              //same minute
              if (myTime[2] == passedTime[2]) {
                //same second
                return 0;
              } else if (myTime[2] < passedTime[2]) {
                return -1;
              } else {
                return 1;
              }
            } else if (myTime[1] < passedTime[1]) {
              return -1;
            } else {
              return 1;
            }
          } else if (myTime[0] < passedTime[0]) {
            return -1;
          } else {
            return 1;
          }
        } else if (myDate[2] < passedDate[2]) {
          return -1;
        } else {
          return 1;
        }
      } else if (myDate[1] < passedDate[1]) {
        return -1;
      } else {
        return 1;
      }
    } else if (myDate[0] < passedDate[0]) {
      return -1;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> myTime = time.split(':').map(int.parse).toList();
    List<int> myDate = date.split('/').map(int.parse).toList();

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderDisplayName,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            DateFormat.jm().format(DateTime(myDate[0], myDate[1], myDate[2],
                myTime[0], myTime[1], myTime[2])),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
