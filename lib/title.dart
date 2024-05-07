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
    Timer(Duration(seconds: 0), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration:
              Duration(milliseconds: 1500), // Set duration to 500 milliseconds
        ),
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
    return Hero(
      tag: 'logoTag', // Unique tag for the hero animation
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return RotationTransition(
          turns: animation,
          child: fromHeroContext.widget,
        );
      },
      createRectTween: (begin, end) {
        return Tween(begin: begin, end: end);
      },
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/OmeChat_Logo.png',
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
