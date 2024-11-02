import 'dart:developer';
import 'package:chat_me/view/Home.dart';
import 'package:chat_me/model/Model.dart';
import 'package:chat_me/view/Sign_up.dart';
import 'package:chat_me/view/StaticData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
        print(user!.displayName);
        print(user.email);

        print(user.photoURL);
        print(user.uid);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
        } else if (e.code == 'invalid-credential') {}
      }
    }

    return user;
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          SizedBox(
              height: height,
              width: width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.25,
                      width: width * 0.4,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("images/main.png"))),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.85,
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.85,
                      child: TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black38)),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: "Email"),
                        controller: _emailController,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    SizedBox(
                      height: height * 0.06,
                      width: width * 0.85,
                      child: TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.password),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black38)),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: "Password"),
                        controller: _passwordController,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    SizedBox(
                      height: height * 0.04,
                      width: width * 0.85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Forget Password ?",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    InkWell(
                      onTap: () async {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();

                        // Check if email or password is empty
                        if (email.isEmpty || password.isEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "Email and password are required", // Message displayed in the toast
                              toastLength:
                                  Toast.LENGTH_SHORT, // Short duration toast
                              gravity: ToastGravity
                                  .BOTTOM, // Position the toast at the bottom
                              backgroundColor: Colors
                                  .orangeAccent, // Background color of the toast
                              textColor:
                                  Colors.black, // Text color of the toast
                              fontSize: 16.0 // Font size for the toast message
                              );
                          log("Email and password are required");
                          return; // Stop further execution if fields are empty
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          // Firebase query if both fields are filled
                          QuerySnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection("User")
                              .where("email", isEqualTo: email)
                              .where("password", isEqualTo: password)
                              .get();

                          if (snapshot.docs.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Incorrect Email or Password",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.orangeAccent,
                                textColor: Colors.black,
                                fontSize: 16.0);
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            UserModel model = UserModel.fromMap(snapshot.docs[0]
                                .data() as Map<String, dynamic>);
                            log("Login Sucessfully");
                            setState(() {
                              isLoading = false;
                            });
                            print(model);
                            StaticData.model = model;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 3,
                        child: Container(
                          height: height * 0.06,
                          width: width * 0.85,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "Sign in",
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    SizedBox(
                      height: height * 0.04,
                      width: width * 0.72,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Don't have a account ?",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ));
                            },
                            child: Container(
                              child: Text(
                                "Sign up",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    SizedBox(
                      height: height * 0.03,
                      width: width * 0.95,
                      child: Center(
                        child: Text("---------- or ----------",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                )),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            signInWithGoogle(context: context);
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("images/google2.jpg"),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage("images/images f.png"),
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage("images/imgs.webp"),
                        ),
                      ],
                    )
                  ])),
          isLoading == false
              ? SizedBox()
              : Container(
                  height: height,
                  width: width,
                  color: Colors.white.withOpacity(0.1),
                  child: SpinKitFadingCircle(
                    color: Colors.black,
                    size: 70.0,
                  ),
                )
        ],
      ),
    ));
  }
}
