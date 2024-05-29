// home_page.dart

// ignore_for_file: prefer_const_constructors, avoid_print, use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading_screen.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({Key? key, this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showButton = false;
  String userName = 'Anonymous';
  String userProfilePicture =
      'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fetchUserData(widget.user!.uid);
    } else {
      _signInAnonymouslyAndFetchUserData();
    }
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  Future<void> _signInAnonymouslyAndFetchUserData() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      if (user != null) {
        _fetchUserData(user.uid);
      }
    } catch (e) {
      print('Error during anonymous sign-in: $e');
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'Anonymous';
          userProfilePicture =
              'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/${userDoc['profilePicture']}.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011';
        });
        print('Fetched user data successfully');
      } else {
        print('No such document!');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${e.message}'),
        ),
      );
    } catch (e) {
      print("Unknown error occurred:");
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(180, 74, 26, 1),
        actions: [
          GestureDetector(
            onTap: () async {
              final user = await Navigator.push<User>(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );

              if (user != null) {
                setState(() {
                  _fetchUserData(user.uid);
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userProfilePicture),
                      radius: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/scribble.png",
                    fit: BoxFit.cover,
                  ),
                  Hero(
                    tag: 'logoTag',
                    flightShuttleBuilder: (
                      BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext,
                    ) {
                      return RotationTransition(
                        turns: animation,
                        child: toHeroContext.widget,
                      );
                    },
                    createRectTween: (begin, end) {
                      return MaterialRectCenterArcTween(begin: begin, end: end);
                    },
                    child: Image.asset(
                      "assets/OmeChat_Logo.png",
                      width: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showButton)
            Positioned(
              bottom: 175,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signInAnonymously,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'START',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
