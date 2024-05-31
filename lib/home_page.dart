import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'services/home_operations.dart';

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
        updateShowButtonState(
            _controller,
            _connectivityResult,
            _animationCompleted,
            setShowButton); // Update the show button state whenever connectivity changes
      });
    });
    if (widget.user != null) {
      fetchUserData(widget.user!.uid, setUserName, setUserProfilePicture);
    } else {
      signInAnonymouslyAndFetchUserData(_auth, (String userId) {
        fetchUserData(userId, setUserName, setUserProfilePicture);
      });
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animationCompleted = true;
          });
          updateShowButtonState(
              _controller,
              _connectivityResult,
              _animationCompleted,
              setShowButton); // Update the show button state when animation completes
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

  void setShowButton(bool value) {
    setState(() {
      _showButton = value;
    });
  }

  void setUserName(String name) {
    setState(() {
      userName = name;
    });
  }

  void setUserProfilePicture(String profilePicture) {
    setState(() {
      userProfilePicture = profilePicture;
    });
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
                          fetchUserData(
                              user.uid, setUserName, setUserProfilePicture);
                        });
                      }
                    },
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(userProfilePicture),
                            ),
                          ),
                        ),
                      ],
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
          Positioned(
            bottom: 175,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: Visibility(
                  visible: _showButton,
                  child: ElevatedButton(
                    onPressed: () => findPair(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 29, 94, 19), width: 1.0),
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
          )
        ],
      ),
    );
  }
}
