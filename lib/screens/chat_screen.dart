// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widgets/chat/messages.dart';
import '../widgets/chat/new_message.dart';

class ChatScreen extends StatefulWidget {
  // const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // final fbm = FirebaseMessaging();
    final fbm = FirebaseMessaging.instance;

    // if (Platform.isIOS) {
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chat');

    //This step will ask ios users for push notifications permission.

    // }
    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyChat'),
        actions: [
          DropdownButton(
            underline: Container(),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.pink,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              //this will ensure that listview only takes space as much space as available on the screen.
              child: Messages(),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}


/*
// [1] STARTED WITH : 
 body: ListView.builder(
        itemCount: 10,
        itemBuilder: (ctx, index) => Container(
          padding: EdgeInsets.all(8),
          child: Text('This works!'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Firestore.instance
              .collection('chats/DSGmhl46ert2o2Fb8W61/messages')
              .snapshots() //this sets listener from flutter to firebase datastorage.
              .listen((data) {
            //this function will be called whenever there is new data!
            // print(data.documents[0]['text']);

            //we can also call function to call on each document like this :
            data.documents.forEach(
              (document) {
                print(document['text']);
              },
            );
          }); //emits new data whenever data changes! [REALTIME DATA]
          // print('');
        },
      ),
*/

/*
2] only simple stream builder : 
body:StreamBuilder(
        builder: (ctx, streamSnapshot) {
          //this function will be executed whenever we get a new value from snapshot!
          //this will not update the whole UI. Instead it will only check if something is missing or has to be update! so this will be very EFFICIENT
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = streamSnapshot.data.documents;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) => Container(
              padding: EdgeInsets.all(8),
              child: Text(documents[index]['text']),
            ),
          );
        },
        stream: Firestore.instance
            .collection('chats/DSGmhl46ert2o2Fb8W61/messages')
            .snapshots(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Firestore.instance
              .collection('chats/DSGmhl46ert2o2Fb8W61/messages')
              .add({
            'text': 'This was added by clicking the button',
          }); //on flutter side new document is represented by MAP.
        },
      ),
*/