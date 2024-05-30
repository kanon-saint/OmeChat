import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _shouldStoreUserId = true;
  int _currentPage = 0;
  final List<Map<String, String>> _messages = [
    {
      'title': 'Talking to Strangers',
      'subtitle': 'Remember to be cautious while talking to strangers online.'
    },
    {
      'title': 'Stay Safe',
      'subtitle':
          'Avoid sharing personal information with people you don\'t know well.'
    },
    {
      'title': 'Enjoy the Conversation',
      'subtitle':
          'Have fun while meeting new people, but always prioritize your safety.'
    },
  ];
  late StreamController<int> _pageControllerStream;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageControllerStream = StreamController<int>();
    _startTimer();
    printCurrentUserUID(); // Print current user's UID
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageControllerStream.close();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _pageControllerStream.add(_currentPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              _shouldStoreUserId = false;
              await deleteUserFromFirestore();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20), // Adjust the padding as needed
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: _pageControllerStream.stream,
                    initialData: 0,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      _currentPage = snapshot.data ?? 0;
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                  0.5), // Gray transparent background
                              borderRadius: BorderRadius.circular(
                                  10), // Optional: border radius
                            ),
                            padding: EdgeInsets.all(
                                10), // Optional: padding for texts
                            child: ListTile(
                              title: Text(
                                _messages[_currentPage % _messages.length]
                                    ['title']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      20, // Increase the font size for title
                                ),
                              ),
                              subtitle: Text(
                                _messages[_currentPage % _messages.length]
                                    ['subtitle']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      16, // Increase the font size for content
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.grey[350],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Get current user
                      User? user = FirebaseAuth.instance.currentUser;
                      _shouldStoreUserId = false;
                      if (user != null) {
                        // User is signed in
                        String userId = user.uid;
                        // Delete user from "users" collection
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .delete();
                          print(
                              'User $userId deleted from "users" collection.');
                        } catch (error) {
                          print(
                              'Failed to delete user $userId from "users" collection: $error');
                        }
                      }
                      // Navigate back to the home page
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> printCurrentUserUID() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in
      String userId = user.uid;

      // Store current user's ID to Firestore
      await storeUserIDToFirestore(userId);

      // Navigate to chat room if user is present in any room
      navigateToChatRoom(userId);
    } else {
      // No user is signed in
      print('No user signed in.');
    }
  }

  Future<void> storeUserIDToFirestore(String userId) async {
    try {
      // Check if the "users" collection exists
      final usersCollection = FirebaseFirestore.instance.collection('users');

      // Store the user ID since either the collection doesn't exist or it has less than two documents
      await Future.delayed(const Duration(seconds: 3));
      await usersCollection.doc(userId).set({});
      print('User ID $userId stored to Firestore successfully.');
    } catch (error) {
      print('Failed to store user ID to Firestore: $error');
    }
  }

  void navigateToChatRoom(String userId) {
    // Use StreamBuilder to continuously monitor the rooms collection for the user's presence
    FirebaseFirestore.instance
        .collection('rooms')
        .where('occupant1', isEqualTo: userId)
        .snapshots()
        .listen((querySnapshot1) {
      if (querySnapshot1.docs.isNotEmpty) {
        // User is present in a room, navigate to chat room
        String roomId = querySnapshot1.docs.first.id;
        List<String> occupants = [
          querySnapshot1.docs.first['occupant1'],
          querySnapshot1.docs.first['occupant2']
        ];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomId: roomId,
              occupants: occupants,
              currentUserId: userId, // Pass the current user's ID
            ),
          ),
        );
        return;
      }

      FirebaseFirestore.instance
          .collection('rooms')
          .where('occupant2', isEqualTo: userId)
          .snapshots()
          .listen((querySnapshot2) {
        if (querySnapshot2.docs.isNotEmpty) {
          // User is present in a room, navigate to chat room
          String roomId = querySnapshot2.docs.first.id;
          List<String> occupants = [
            querySnapshot2.docs.first['occupant1'],
            querySnapshot2.docs.first['occupant2']
          ];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                roomId: roomId,
                occupants: occupants,
                currentUserId: userId, // Pass the current user's ID
              ),
            ),
          );
        }
      });
    });
  }

  Future<void> deleteUserFromFirestore() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in
      String userId = user.uid;
      // Delete user from "users" collection
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
        print('User $userId deleted from "users" collection.');
      } catch (error) {
        print('Failed to delete user $userId from "users" collection: $error');
      }
    }
  }
}
