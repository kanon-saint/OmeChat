import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omechat/chat_room_screen.dart';

Future<void> printCurrentUserUID(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;
    await storeUserIDToFirestore(userId);
    navigateToChatRoom(context, userId);
  } else {
    print('No user signed in.');
  }
}

Future<void> storeUserIDToFirestore(String userId) async {
  try {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await Future.delayed(const Duration(seconds: 3));
    await usersCollection.doc(userId).set({});
    print('User ID $userId stored to Firestore successfully.');
  } catch (error) {
    print('Failed to store user ID to Firestore: $error');
  }
}

void navigateToChatRoom(BuildContext context, String userId) {
  FirebaseFirestore.instance
      .collection('rooms')
      .where('occupant1', isEqualTo: userId)
      .snapshots()
      .listen((querySnapshot1) {
    if (querySnapshot1.docs.isNotEmpty) {
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
            currentUserId: userId,
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
              currentUserId: userId,
            ),
          ),
        );
      }
    });
  });
}

Future<void> deleteUserFromFirestore() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('User $userId deleted from "users" collection.');
    } catch (error) {
      print('Failed to delete user $userId from "users" collection: $error');
    }
  }
}
