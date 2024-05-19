import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'loading_screen.dart'; // Assuming this is your loading screen
import 'profile.dart'; // Import your ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return Stack(
            fit: StackFit.expand,
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromRGBO(180, 74, 26, 1),
                  actions: connected
                      ? [
                          GestureDetector(
                            onTap: () {
                              // Navigate to ProfilePage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Anonymous',
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
                        ]
                      : null,
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
                                return MaterialRectCenterArcTween(
                                    begin: begin, end: end);
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
                      bottom: 175, // Adjust as needed
                      left: 0,
                      right: 0,
                      child: Center(
                        child: connected
                            ? SizedBox(
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
                              )
                            : Text(
                                'You are offline. Please connect to the internet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
