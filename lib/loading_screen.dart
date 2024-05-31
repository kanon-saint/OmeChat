import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late StreamController<int> _pageControllerStream;
  late Timer _timer;
  late StreamSubscription<ConnectivityResult> _subscription;
  int _currentPage = 0;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
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

  @override
  void initState() {
    super.initState();
    _pageControllerStream = StreamController<int>();
    _startTimer();
    printCurrentUserUID(); // Print current user's UID
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          Navigator.pop(
              context); // Go back to the home page if there is no internet connection
        }
      });
    });
  }

  @override
  void dispose() {
    _pageControllerStream.close();
    _timer.cancel();
    _subscription.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _pageControllerStream.add(_currentPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              _timer.cancel();
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(
                                10), // Padding for the container
                            child: ListTile(
                              title: Text(
                                _messages[_currentPage % _messages.length]
                                    ['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20, // Font size for the title text
                                ),
                              ),
                              subtitle: Text(
                                _messages[_currentPage % _messages.length]
                                    ['subtitle']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      16, // Font size for the subtitle text
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.grey[350],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cancelFindPair,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(181, 16, 24, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 124, 3, 3), width: 1.0),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
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

  void _cancelFindPair() {
    _timer.cancel();
    Navigator.pop(context);
  }
}
