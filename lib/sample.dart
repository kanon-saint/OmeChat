import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';
import 'home_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    printCurrentUserUID(); // Print current user's UID
    getUsersFromFirestore(); // Fetch all user IDs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Match'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void printCurrentUserUID() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in
      print('Current User UID: ${user.uid}');

      // Store current user's ID to Firestore
      await storeUserIDToFirestore(user.uid);
    } else {
      // No user is signed in
      print('No user signed in.');
    }
  }

  Future<void> storeUserIDToFirestore(String uid) async {
    final firestoreInstance = FirebaseFirestore.instance;

    // Create a collection reference
    CollectionReference users = firestoreInstance.collection('users');

    // Create a document reference using the user ID
    DocumentReference userDocRef = users.doc(uid);

    // Set the data to be stored in the document
    await userDocRef.set({'uid': uid});
  }

  void getUsersFromFirestore() async {
    final firestoreInstance = FirebaseFirestore.instance;

    // Create a collection reference
    CollectionReference users = firestoreInstance.collection('users');

    // Fetch all documents from the collection
    QuerySnapshot querySnapshot = await users.get();

    // Extract user IDs
    List<String> ids = [];
    querySnapshot.docs.forEach((doc) {
      ids.add(doc['uid']);
    });

    // Shuffle the user IDs
    ids.shuffle();

    // Create pairs and store them in Firestore
    await createAndStorePairs(ids);

    // Navigate to the chat room
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatRoomScreen()),
    );
  }

  Future<void> createAndStorePairs(List<String> ids) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final CollectionReference pairs = firestoreInstance.collection('pairs');
    final CollectionReference users = firestoreInstance.collection('users');

    // Determine the number of pairs
    int numPairs = ids.length ~/ 2;

    // Generate room IDs
    List<String> roomIDs = List.generate(numPairs, (_) => generateRoomID());

    // Create pairs
    for (int i = 0; i < numPairs; i++) {
      String roomID = roomIDs[i];
      String userID1 = ids[2 * i];
      String userID2 = ids[2 * i + 1];

      // Store pair in Firestore
      DocumentReference pairDocRef = await pairs.add({
        'roomID': roomID,
        'userIDs': [userID1, userID2],
      });

      print(roomID);

      // Remove user IDs from "users" collection
      await users.doc(userID1).delete();
      await users.doc(userID2).delete();
    }
  }

  String generateRoomID() {
    // Generate a random room ID
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    String roomID = '';
    for (int i = 0; i < 6; i++) {
      roomID += characters[random.nextInt(characters.length)];
    }
    return roomID;
  }
}
