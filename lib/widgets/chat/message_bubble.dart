// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Key key;
  final String userName;
  final String userImage;
  final bool isNew;
  final messageTime;

  MessageBubble(this.messageTime, this.isNew, this.message, this.userName,
      this.userImage, this.isMe,
      {this.key});

  String getTime(var time) {
    final DateFormat formatter = DateFormat('hh:mm aa');
    var date = time.toDate();
    // var date = time.toDate().toString();
    return formatter.format(date);
    // return date;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              // width: MediaQuery.of(context).size.width / 1.2,
              // width: 140,
              constraints: BoxConstraints(
                // minWidth: 140,
                maxWidth: MediaQuery.of(context).size.width / 1.2,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.only(
                right: 8,
                left: 8,
                bottom: 3,
                top: isNew ? 10 : 3,
                // top: 4,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isNew)
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.black : Colors.white,
                        // : Theme.of(context).accentTextTheme.headline1.color,
                      ),
                    ),
                  // Text(
                  //   message,
                  //   textAlign: isMe ? TextAlign.end : TextAlign.start,
                  //   style: TextStyle(
                  //     color: isMe
                  //         ? Colors.black
                  //         : Theme.of(context).accentTextTheme.headline1.color,
                  //   ),
                  // ),
                  // Text(
                  //   '12:37 PM',
                  //   style: TextStyle(
                  //     color: isMe ? Colors.black : Colors.white,
                  //     fontSize: 10,
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // ),
                  RichText(
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: message,
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                          ),
                        ),
                        //Message time :
                        TextSpan(
                          text: '\t\t\t~ ${getTime(messageTime)}',
                          // text: '\t\t\t~ 12:37 PM',
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isNew)
              Positioned(
                top: -10,
                right: isMe ? null : -10,
                left: !isMe ? null : -10,
                // alignment: isMe ? Alignment.topLeft : Alignment.bottomLeft,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                ),
              ),
          ],
          clipBehavior: Clip.none,
        ),
      ],
    );
  }
}

/*
OLDER APPROACH OF FETCHING USERNAME EVERYTIME WITH FUTUREBUILDER AND USER ID  : 
FutureBuilder(
                  future: Firestore.instance
                      .collection('users')
                      .document(userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    return Text(
                      snapshot.data['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe
                            ? Colors.black
                            : Theme.of(context).accentTextTheme.headline1.color,
                      ),
                    );
                  },
                ),
*/
