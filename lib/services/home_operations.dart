import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:omechat/loading_screen.dart';

Future<void> fetchUserData(String userId, Function(String) setUserName,
    Function(String) setUserProfilePicture) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('accounts')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      setUserName(userDoc['name'] ?? 'Anonymous');
      setUserProfilePicture(
          'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/${userDoc['profilePicture']}.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011');
      print('Fetched user data successfully');
    } else {
      await FirebaseFirestore.instance.collection('accounts').doc(userId).set({
        'gender': 'Unknown',
        'interests': '',
        'name': 'Anonymous',
        'profilePicture': 'profile1',
      });
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}

Future<void> signInAnonymouslyAndFetchUserData(
    FirebaseAuth auth, Function(String) onUserSignedIn) async {
  try {
    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    if (user != null) {
      onUserSignedIn(user.uid);
    }
  } catch (e) {
    print('Error signing in anonymously: $e');
  }
}

void updateShowButtonState(
    AnimationController controller,
    ConnectivityResult connectivityResult,
    bool animationCompleted,
    Function(bool) setShowButton) {
  setShowButton(
      animationCompleted && connectivityResult != ConnectivityResult.none);
}

Future<void> findPair(BuildContext context) async {
  try {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()));
  } catch (e) {
    print('Error finding pair: $e');
  }
}
