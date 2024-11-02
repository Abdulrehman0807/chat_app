import 'dart:developer';
import 'package:chat_me/view/Home.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_me/view/Login.dart';
import 'package:chat_me/model/Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

bool isLoading = false;

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;

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
        log('User signed in: ${user?.displayName}');
      } on FirebaseAuthException catch (e) {
        log('FirebaseAuthException: ${e.message}');
        if (e.code == 'account-exists-with-different-credential') {
          log('Account exists with different credentials.');
          Fluttertoast.showToast(
            msg: "Account exists with different credentials.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } else if (e.code == 'invalid-credential') {
          log('Invalid credentials.');
          Fluttertoast.showToast(
            msg: "Invalid credentials.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        log('Error signing in: $e');
        Fluttertoast.showToast(
          msg: "Error signing in: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // User canceled the Google sign-in
      Fluttertoast.showToast(
        msg: "Google sign-in canceled.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    return user;
  }

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
                    image:
                        DecorationImage(image: AssetImage("images/main.png")),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  height: height * 0.06,
                  width: width * 0.85,
                  child: Text(
                    "Register",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  height: height * 0.06,
                  width: width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black38)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Username"),
                    controller: nameController,
                  ),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                Container(
                  height: height * 0.06,
                  width: width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black38)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
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
                Container(
                  height: height * 0.06,
                  width: width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black38)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Password"),
                    controller: _passwordController,
                  ),
                ),
                SizedBox(
                  height: height * 0.004,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    Text(
                      "Remember me",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.002,
                ),
                InkWell(
                  onTap: () async {
                    String email = _emailController.text.trim();
                    String name = nameController.text.trim();
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
                          textColor: Colors.black, // Text color of the toast
                          fontSize: 16.0 // Font size for the toast message
                          );
                      log("Email and password are required");
                      return; // Stop further execution if fields are empty
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      QuerySnapshot existingUser = await FirebaseFirestore
                          .instance
                          .collection("User")
                          .where("email", isEqualTo: email)
                          .get();

                      // If the email exists, show a message and stop the process
                      if (existingUser.docs.isNotEmpty) {
                        Fluttertoast.showToast(
                            msg: "This email is already registered",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.orangeAccent,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        return;
                      }

                      // If the email doesn't exist, proceed with signup
                      var uuid = const Uuid();
                      String userId = uuid.v4();

                      UserModel model = UserModel(
                        name: name,
                        email: email,
                        password: password,
                        UserId: userId,
                      );

                      // Save the user to Firestore
                      await FirebaseFirestore.instance
                          .collection("User")
                          .doc(userId)
                          .set(model.toMap());

                      log("User registered with ID: $userId");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Signinscreen(),
                        ),
                      );
                    }
                    // Check if the email already exists in the Firestore collection
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
                          "Sign up",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.005,
                ),
                SizedBox(
                  height: height * 0.04,
                  width: width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Already have a account ?",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Signinscreen(),
                              ));
                        },
                        child: Container(
                          child: Text(
                            "Sign in",
                            style: Theme.of(context).textTheme.displayLarge,
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
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
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
                      onTap: () async {
                        User? user = await signInWithGoogle(context: context);
                        if (user != null) {
                          // Navigate to the next screen if authentication is successful
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        } else {
                          // Show a toast if authentication failed
                          Fluttertoast.showToast(
                            msg: "Authentication unsuccessful",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.orangeAccent,
                            textColor: Colors.white,
                          );
                        }
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
              ],
            ),
          ),
          isLoading == false
              ? SizedBox()
              : Container(
                  height: height,
                  width: width,
                  color: Colors.white.withOpacity(0.01),
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
