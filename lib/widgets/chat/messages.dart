// import 'dart:math';

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
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          ) //by default it is in accending order.
          .snapshots(), //with ordering by timestamps!
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: AdaptiveCircularProgressIndicator(false),
          );
        }

        final chatDocs = chatSnapshot.data.docs;
        // print('CHATS_DATA : ${chatDocs.data()}');
        for (int i = 0; i < chatDocs.length; i++) {
          print(
              'data for index : $i\n\t on ${getDateStr(chatDocs[i].data()['createdAt'])} ${chatDocs[i].data()['username']} : ${chatDocs[i].data()['text']}');
        }

        return ListView.separated(
          reverse: true,
          itemBuilder: (context, index) {
            // bool loadNew = false;
            bool loadNew = (index == chatDocs.length - 1) ||
                (index != chatDocs.length - 1 &&
                    chatDocs[index + 1].data()['userId'] !=
                        chatDocs[index].data()['userId']);
            if (index == chatDocs.length - 1) {
              var dateMessage = getDateStr(chatDocs[index].data()['createdAt']);
              print(
                  'index end : itembuilder. DateSepator builded. || $dateMessage');
              return Column(
                children: [
                  _buildDateSeparator(dateMessage),
                  _buildMessage(
                    chatDocs: chatDocs,
                    loadNew: loadNew,
                    index: index,
                    user: user,
                  ),
                ],
              );
            }
            print(
                'index $index : itembuilder. Message builded. || ${chatDocs[index].data()['text']}');
            return _buildMessage(
              chatDocs: chatDocs,
              loadNew: loadNew,
              index: index,
              user: user,
            );
          },
          separatorBuilder: (context, index) {
            if (index == chatDocs.length - 1) {
              print('\tno separator.');
              return SizedBox();
            }
            final currentMessageDate =
                chatDocs[index].data()['createdAt'].toDate();
            // if (index == chatDocs.length - 1) {
            //   var dateMessage =
            //       getDateStr(chatDocs[index - 1].data()['createdAt']);
            //   return _buildDateSeparator(dateMessage);
            // }
            // print('accessing overflow : $index ${chatDocs.length}');
            final nextMessageDate =
                chatDocs[index + 1].data()['createdAt'].toDate();
            if (!_isSameDate(currentMessageDate, nextMessageDate)) {
              var dateMessage =
                  getDateStr(chatDocs[index - 1].data()['createdAt']);
              print('\tDate separator. || $dateMessage');
              return _buildDateSeparator(dateMessage);
            }
            print('\tno separator end.');
            return SizedBox();
          },
          itemCount: chatDocs.length,
          // itemCount: chatDocs.length + (chatDocs.isNotEmpty ? 1 : 0),
        );
      },
    );
  }

  Widget _buildDateSeparator(String dateMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // key: GlobalObjectKey(putMessage),
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5),
          child: Text(
            dateMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          constraints: BoxConstraints(),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    @required var chatDocs,
    @required bool loadNew,
    @required int index,
    @required var user,
  }) {
    return Column(
      children: [
        if (loadNew)
          SizedBox(
            height: 15,
          ),
        MessageBubble(
          chatDocs[index].data()['createdAt'],
          loadNew ? true : false,
          chatDocs[index].data()['text'],
          chatDocs[index].data()['username'],
          chatDocs[index].data()['userImage'] ?? _defaultProfileImage,
          chatDocs[index].data()['userId'] ==
              user.uid, //checks wheather the message is mine or the other user.
          key: ValueKey(
            chatDocs[index]
                .id, //this will ensure that flutter will efficiently re render the UI !
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}


/*

return MessageBubble(
              chatDocs[index]['createdAt'],
              false,
              chatDocs[index]['text'],
              chatDocs[index]['username'],
              chatDocs[index]['userImage'],
              chatDocs[index]['userId'] ==
                  futureSnapshot.data
                      .uid, //checks wheather the message is mine or the other user.
              key: ValueKey(
                chatDocs[index]
                    .documentID, //this will ensure that flutter will efficiently re render the UI !
              ),
            );
*/

/*
//OLDER APPROACH : 
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
          stream: FirebaseFirestore.instance
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
*/

/*
// OLDER APPROACH FOR LISTVIEW WITH DATE SEPARATOR : 
return ListView.builder(
          // addSemanticIndexes: false,
          // addAutomaticKeepAlives: false,
          // addRepaintBoundaries: false,
          // cacheExtent: 10,
          reverse: true,
          itemBuilder: (ctx, index) {
            var putMessage;
            bool putDate = false;
            String currentDate;
            var nextDate;
            if (index == 0) {
              datesMessage = getDateStr(chatDocs[index].data()['createdAt']);

              currentDate = datesMessage;
            } else {
              currentDate = getDateStr(chatDocs[index].data()['createdAt']);
            }
            if (index != chatDocs.length - 1)
              nextDate = getDateStr(chatDocs[index + 1].data()['createdAt']);

            // print('for $index : $datesMessage $currentDate');
            bool loadNew = (index == chatDocs.length - 1) ||
                (index != chatDocs.length - 1 &&
                    chatDocs[index + 1].data()['userId'] !=
                        chatDocs[index].data()['userId']) ||
                (currentDate != nextDate);

            if (index != 0 && datesMessage != currentDate) {
              putMessage = datesMessage;
              datesMessage = currentDate;
              putDate = true;
              print('date changed.');
            } else {
              putDate = false;
            }
            // putDate = false;
            return Column(
              children: [
                // if (index == chatDocs.length - 1) Text(currentDate),
                if (loadNew)
                  SizedBox(
                    height: 15,
                  ),
                MessageBubble(
                  chatDocs[index].data()['createdAt'],
                  loadNew ? true : false,
                  chatDocs[index].data()['text'],
                  chatDocs[index].data()['username'],
                  chatDocs[index].data()['userImage'] ?? _defaultProfileImage,
                  chatDocs[index].data()['userId'] ==
                      user.uid, //checks wheather the message is mine or the other user.
                  key: ValueKey(
                    chatDocs[index]
                        .id, //this will ensure that flutter will efficiently re render the UI !
                  ),
                ),
                if (putDate)
                  Container(
                    // key: GlobalObjectKey(putMessage),
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
          },
          itemCount: chatDocs.length,
        );
*/