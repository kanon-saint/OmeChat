import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> storeUserIDToFirestore(String uid) async {
  final firestoreInstance = FirebaseFirestore.instance;

  // Create a collection reference
  CollectionReference users = firestoreInstance.collection('users');

  // Create a document reference using the user ID
  DocumentReference userDocRef = users.doc(uid);

  // Set the data to be stored in the document
  await userDocRef.set({'uid': uid});
}

Future<List<String>> getUsersFromFirestore() async {
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

  return ids;
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
