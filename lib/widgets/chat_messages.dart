import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: false,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages yet'),
            );
          }
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              // reverse: false,
              itemCount: loadedMessages.length,
              itemBuilder: (cntx, index) {
                final chatMessage = loadedMessages[index].data();
                // check if there is a next message. Otherwise null.
                final prevChatMessage =
                    index - 1 >= 0 ? loadedMessages[index - 1].data() : null;

                // compare userId of the current and next messages
                final currentMessageUserId = chatMessage['userId'];
                final prevMessageUserId =
                    prevChatMessage != null ? prevChatMessage['userId'] : null;

                final prevUserIsSame =
                    currentMessageUserId == prevMessageUserId;

                // display a widget depending on whether it is a first message of this user
                if (prevUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser!.uid == currentMessageUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['image_url'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser!.uid == currentMessageUserId,
                  );
                }
              });
        });
  }
}
