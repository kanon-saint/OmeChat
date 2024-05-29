import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import home page

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home page after 1 second
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(
              milliseconds: 3000), // Set transition duration to 3 seconds
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LogoWidget(),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

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
        decoration: const BoxDecoration(
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
