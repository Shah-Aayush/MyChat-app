import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../circular_loading_spinner.dart';
import './message_bubble.dart';

// ignore: must_be_immutable
class Messages extends StatelessWidget {
  var datesMessage;
  final _defaultProfileImage =
      'https://firebasestorage.googleapis.com/v0/b/mychat-theflutterapp.appspot.com/o/user_images%2Fperson_placeholder.png?alt=media&token=d731be98-e167-46fe-a5c1-52744d3fdf23';

  String getDateStr(var date) {
    // final DateFormat formatter = DateFormat('d MMMMMMM, yyyy');
    var dateStr = date.toDate();
    return DateFormat.yMMMMd().format(dateStr);
    // return formatter.format(dateStr);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: AdaptiveCircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          stream: Firestore.instance
              .collection('chat')
              .orderBy(
                'createdAt',
                descending: true,
              ) //by default it is in accending order.
              .snapshots(), //with ordering by timestamps!
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: AdaptiveCircularProgressIndicator(),
              );
            }
            final chatDocs = chatSnapshot.data.documents;
            return ListView.builder(
              reverse: true,
              itemBuilder: (ctx, index) {
                var putMessage;
                bool putDate = false;

                String currentDate;
                String nextDate;
                if (index == 0) {
                  datesMessage = getDateStr(chatDocs[index]['createdAt']);
                  currentDate = datesMessage;
                } else {
                  currentDate = getDateStr(chatDocs[index]['createdAt']);
                }
                if (index != chatDocs.length - 1)
                  nextDate = getDateStr(chatDocs[index + 1]['createdAt']);

                // print('for $index : $datesMessage $currentDate');
                bool loadNew = (index == chatDocs.length - 1) ||
                    (index != chatDocs.length - 1 &&
                        chatDocs[index + 1]['userId'] !=
                            chatDocs[index]['userId']) ||
                    (currentDate != nextDate);

                if (index != 0 && datesMessage != currentDate) {
                  putMessage = datesMessage;
                  datesMessage = currentDate;
                  putDate = true;
                  print('date changed.');
                } else {
                  putDate = false;
                }

                return Column(
                  children: [
                    // if (index == chatDocs.length - 1) Text(currentDate),
                    if (loadNew)
                      SizedBox(
                        height: 15,
                      ),
                    MessageBubble(
                      chatDocs[index]['createdAt'],
                      loadNew ? true : false,
                      chatDocs[index]['text'],
                      chatDocs[index]['username'],
                      chatDocs[index]['userImage'] ?? _defaultProfileImage,
                      chatDocs[index]['userId'] ==
                          futureSnapshot.data
                              .uid, //checks wheather the message is mine or the other user.
                      key: ValueKey(
                        chatDocs[index]
                            .documentID, //this will ensure that flutter will efficiently re render the UI !
                      ),
                    ),
                    if (putDate)
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          putMessage,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                  ],
                );

                // return MessageBubble(
                //   chatDocs[index]['createdAt'],
                //   false,
                //   chatDocs[index]['text'],
                //   chatDocs[index]['username'],
                //   chatDocs[index]['userImage'],
                //   chatDocs[index]['userId'] ==
                //       futureSnapshot.data
                //           .uid, //checks wheather the message is mine or the other user.
                //   key: ValueKey(
                //     chatDocs[index]
                //         .documentID, //this will ensure that flutter will efficiently re render the UI !
                //   ),
                // );
              },
              itemCount: chatDocs.length,
            );
          },
        );
      },

      // stream: Firestore.instance.collection('chat').snapshots(),   //without ordering
    );
  }
}
