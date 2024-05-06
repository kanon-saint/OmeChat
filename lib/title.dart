import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import home page

class TitlePage extends StatefulWidget {
  @override
  _TitlePageState createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  @override
  void initState() {
    super.initState();
    // Run the home page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LogoWidget(),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 100;
    return Container(
      width: containerWidth,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/OmeChat_Logo.png'), // Replace 'logo.png' with your image asset
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
