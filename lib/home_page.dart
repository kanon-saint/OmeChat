// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loading_screen.dart'; // Assuming this is your loading screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      appBar: AppBar(
        title: const Text('OmeChat'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInAnonymously, // Call the function on press
          child: const Text('Start Chatting'), // Change button text
        ),
      ),
    );
  }
}
