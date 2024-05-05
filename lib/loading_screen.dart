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

      // Fetch all user IDs from Firestore
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((querySnapshot) async {
        List<String> allUserIds = [];
        querySnapshot.docs.forEach((doc) {
          allUserIds.add(doc.id);
        });

        // Pair up the users
        List<List<String>> pairs = [];
        for (int i = 0; i < allUserIds.length; i += 2) {
          if (i + 1 < allUserIds.length) {
            pairs.add([allUserIds[i], allUserIds[i + 1]]);
          } else {
            // If there's an odd number of users, handle the last one separately
            pairs.add([allUserIds[i]]);
          }
        }

        // Store pairs in Firestore with unique room IDs if both users have been paired
        for (int i = 0; i < pairs.length; i++) {
          List<String> pair = pairs[i];
          if (pair.length == 2) {
            String roomId = generateRoomId();
            await FirebaseFirestore.instance
                .collection('rooms')
                .doc(roomId)
                .set({
              'roomID': roomId,
              'occupant1': pair[0],
              'occupant2': pair[1],
            });
            print('Pair $pair stored with Room ID $roomId in Firestore.');

            // Delete users from "users" collection
            for (String userId in pair) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .delete();
              print('User $userId deleted from "users" collection.');
            }
          }
        }

        // Check if the current user is in any room
        await checkUserInRoom(user.uid);
      }).catchError((error) {
        print('Failed to fetch user IDs: $error');
      });
    } else {
      // No user is signed in
      print('No user signed in.');
    }
  }

  Future<void> checkUserInRoom(String userId) async {
    QuerySnapshot roomSnapshot =
        await FirebaseFirestore.instance.collection('rooms').get();
    for (QueryDocumentSnapshot roomDoc in roomSnapshot.docs) {
      List<String> occupants = [roomDoc['occupant1'], roomDoc['occupant2']];
      if (occupants.contains(userId)) {
        // User is in a room, print room details and navigate to chat room
        String roomId = roomDoc['roomID'];
        print(
            'User $userId is in a room with Room ID: $roomId and Occupants: $occupants.');
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
        return; // Exit the function after finding the user in a room
      }
    }
    // If the user is not in any room, print a message and wait before checking again
    print('User $userId is not in any room. Checking again in 5 seconds...');
    // await Future.delayed(const Duration(seconds: 2)); // Wait for 5 seconds
    await checkUserInRoom(userId); // Check again recursively
  }

  Future<void> storeUserIDToFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({});
      print('User ID $userId stored to Firestore successfully.');
    } catch (error) {
      print('Failed to store user ID to Firestore: $error');
    }
  }

  String generateRoomId() {
    // Generate a unique room ID
    String roomId = '';
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    for (int i = 0; i < 6; i++) {
      roomId += chars[random.nextInt(chars.length)];
    }
    return roomId;
  }
}
