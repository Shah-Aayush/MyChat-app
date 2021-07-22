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
    final user = FirebaseAuth.instance.currentUser;
    // final user = await FirebaseAuth.instance.currentUser();
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print('send message Imageurl received : ${userData.data()['image_url']}');

    FirebaseFirestore.instance.collection('chat').add(
      {
        'text': _controller.text,
        'createdAt': Timestamp.now(), //this is from cloud_firestore.
        'userId': user.uid,
        'username': userData.data()['username'],
        'userImage': userData.data()['image_url'],
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
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
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
