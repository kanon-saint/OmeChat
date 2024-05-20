import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loading_screen.dart'; // Assuming this is your loading screen
import 'profile.dart'; // Import your ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    // Hide the button for 3 seconds, then show it
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential != null) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print("FirebaseAuthException occurred:");
      print("Error code: ${e.code}");
      print("Error message: ${e.message}");
      // ignore: use_build_context_synchronously
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
            onTap: () {
              // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Anonymous', // Changed the text to "Anonymous"
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Made the text white
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black, // Set the border color here
                        width: 1.0, // Set the border width here
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
                      ),
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
            top: 100, // Adjust as needed
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
                    tag: 'logoTag', // Same tag used in the title page
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
          if (_showButton) // Display the button only if _showButton is true
            Positioned(
              bottom: 175, // Adjust as needed
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 200, // Set the width to 150
                  height: 50, // Set the height to 150 for a square button
                  child: ElevatedButton(
                    onPressed: _signInAnonymously,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Change the radius here
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'START',
                        textAlign: TextAlign
                            .center, // Center the text horizontally and vertically
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight
                              .bold, // Set FontWeight.bold for bold text
                          fontFamily: 'Roboto', // Change the font family here
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
