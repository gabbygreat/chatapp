import 'package:chatapp/bubble.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:generic_social_widgets/generic_social_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class Message {
  final String uid;
  final String message;
  final Timestamp? timestamp;

  Message({
    required this.uid,
    required this.message,
    this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'message': message,
      'timestamp': timestamp ?? Timestamp.now(),
    };
  }

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return Message(
      uid: data?['uid'],
      message: data?['message'],
      timestamp: data?['timestamp'],
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chat App',
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatting'),
        actions: [
          ElevatedButton(
              onPressed: () async {
                final auth = FirebaseAuth.instance;
                if (auth.currentUser != null) {
                  await auth.signOut();
                } else {
                  await auth.signInAnonymously();
                }
              },
              child: const Text('Log in or Out'))
        ],
      ),
      body: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ///OUR MESSAGE QUERY
  final messagesQuery = FirebaseFirestore.instance
      .collection('messages')
      .orderBy('timestamp', descending: true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        return Column(
          children: [
            Text(
              'User Id: ${authSnapshot.data?.uid}',
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesQuery.snapshots(),
                builder: (context, messagesSnapshot) {
                  if (messagesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (authSnapshot.hasData) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesSnapshot.data!.size,
                      itemBuilder: (BuildContext context, int idx) {
                        final doc = messagesSnapshot.data!.docs[idx]
                            as QueryDocumentSnapshot<Map<String, dynamic>>;
                        final message = Message.fromFirestore(doc);
                        return MyChatBubble(
                          text: message.message,
                          messageUiid: message.uid,
                          uuid: authSnapshot.data!.uid,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (authSnapshot.hasData)
              ChatTextInput(
                onSend: (message) {
                  FirebaseFirestore.instance.collection('messages').add(
                        Message(
                          uid: authSnapshot.data!.uid,
                          message: message,
                        ).toFirestore(),
                      );
                },
              ),
          ],
        );
      },
    );
  }
}
