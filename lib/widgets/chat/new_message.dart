import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = new TextEditingController();

  void _sendMessage() async {
    FocusScope.of(context).unfocus(); //hides the keyboard.
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    print('send message Imageurl received : ${userData['image_url']}');

    Firestore.instance.collection('chat').add(
      {
        'text': _controller.text,
        'createdAt': Timestamp.now(), //this is from cloud_firestore.
        'userId': user.uid,
        'username': userData['username'],
        'userImage': userData['image_url'],
      },
    );
    setState(() {
      _enteredMessage = '';
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            //this will ensure that child takes as much space as available in the row.
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message ...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            onPressed: _enteredMessage.trim().isEmpty
                ? null
                : () {
                    print('Entered message is : .$_enteredMessage.');
                    _sendMessage();
                  }, //Locks the button if message is empty.
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
