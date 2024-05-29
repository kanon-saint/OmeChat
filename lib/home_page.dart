import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loading_screen.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showButton = false;
  String userName = 'Anonymous';
  String userProfilePicture =
      'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011';
  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        _updateShowButtonState(); // Update the show button state whenever connectivity changes
      });
    });
    if (widget.user != null) {
      _fetchUserData(widget.user!.uid);
    } else {
      _signInAnonymouslyAndFetchUserData();
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animationCompleted = true;
          });
          _updateShowButtonState(); // Update the show button state when animation completes
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _updateShowButtonState() {
    setState(() {
      _showButton =
          _animationCompleted && _connectivityResult != ConnectivityResult.none;
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(180, 74, 26, 1),
          actions: _connectivityResult != ConnectivityResult.none
              ? [
                  GestureDetector(
                    onTap: () async {
                      final user = await Navigator.push<User>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
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
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16.0),
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
                ]
              : null,
          bottom: _connectivityResult == ConnectivityResult.none
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(23.0),
                  child: Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'No internet connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
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
                    child: const Center(
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
