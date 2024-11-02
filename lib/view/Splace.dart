import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat_me/view/Sign_up.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnimatedSplashScreen(
      splash: Image.asset("images/under.png",
          width: 120, height: 120, fit: BoxFit.cover),
      splashIconSize: 120,
      duration: 500,
      splashTransition: SplashTransition.rotationTransition,
      pageTransitionType: PageTransitionType.fade,
      nextScreen: const SignupScreen(),
    );
  }
}
