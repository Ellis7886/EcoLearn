import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_page.dart';
import 'register_page.dart';
import '../loading_page.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  Future<void> login() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingPage();
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'isLoggedIn',
        true,
      );

      await prefs.setString(
        'userId',
        FirebaseAuth.instance.currentUser!.uid,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'User is null after login',
        );
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(
          'User document not found in Firestore',
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

    }

    on FirebaseAuthException catch (e) {

      if (mounted) {
        Navigator.pop(context);
      }

      String message = 'Login failed';

      if (e.code == 'user-not-found') {
        message = 'Email does not exist';
      }
      else if (e.code ==
          'wrong-password') {
        message = 'Wrong password';
      }
      else if (e.code ==
          'invalid-email') {
        message = 'Invalid email format';
      }
      else if (e.code ==
          'invalid-credential') {
        message = 'Email or password is wrong';
      }
      else if (e.code ==
          'too-many-requests') {
        message = 'Too many attempts, please try again later';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(message),
        ),
      );
    }

    catch (e) {

      if (mounted) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/ecolearn_logo.png',
              height: 180,
            ),

            const SizedBox(
              height: 40,
            ),

            TextField(
              controller: emailController,

              style: const TextStyle(color: Colors.white,),

              decoration:
              InputDecoration(
                hintText:
                'Email',

                hintStyle:
                const TextStyle(color: Colors.white54,),

                filled: true,

                fillColor: const Color(0xFF2B2B2B,),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller: passwordController,

              obscureText: true,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                hintText: 'Password',

                hintStyle:
                const TextStyle(
                  color: Colors.white54,
                ),

                filled: true,

                fillColor:
                const Color(0xFF2B2B2B,),

                border:
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton(
                onPressed: login,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF9BD028,
                  ),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: const Text(
                  'Login',

                  style: TextStyle(
                    color: Colors.black,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ForgotPasswordPage(),
                      ),
                    );
                  },

                  child:
                  const Text(
                    'Forgot Password?',

                    style: TextStyle(
                      color: Color(0xFF9BD028,),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),

                  child: Text(
                    '|',

                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const RegisterPage(),
                      ),
                    );
                  },

                  child:
                  const Text(
                    'Register',
                    style: TextStyle(
                      color: Color(0xFF9BD028,),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}