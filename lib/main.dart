import 'package:chat_me/view/Splace.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
          primarySwatch: Colors.orange,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            displayMedium: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 18,
                color: Color.fromARGB(255, 87, 83, 83),
                fontWeight: FontWeight.bold),
            displaySmall: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          )),
      home: SplachScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
