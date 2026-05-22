import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'loading_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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

      final user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final role = userDoc['role'];

      Navigator.pop(context);

      if(role=="student"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }else if(role=="lecturer"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    }
    on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String message = 'Login failed';

      if(e.code == 'user-not-found'){
        message = 'Email does not exist';
      }
      else if(e.code == 'wrong-password'){
        message = 'Wrong password';
      }
      else if(e.code == 'invalid-email'){
        message = 'Invalid email format';
      }
      else if(e.code == 'invalid-credential'){
        message = 'Email or password is wrong';
      }
      else if(e.code == 'too-many-requests'){
        message = 'Too many attempts, please try again later';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/ecolearn_logo.png',
              height: 180,
            ),

            const SizedBox(height: 40),

            TextField(
              controller: emailController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(color: Colors.white54),

                filled: true,
                fillColor: const Color(0xFF2B2B2B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white54),

                filled: true,
                fillColor: const Color(0xFF2B2B2B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: login,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9BD028),
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
          ],
        ),
      ),
    );
  }
}