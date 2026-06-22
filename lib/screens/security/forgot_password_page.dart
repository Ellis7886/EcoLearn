import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final emailController =
  TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {

    final email =
    emailController.text.trim();

    if (email.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text('Please enter your email'),
        ),
      );

      return;
    }

    try {

      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset link sent. Please check your email.',
          ),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Failed to send reset email',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {

    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              'Enter your registered email address. A password reset link will be sent to your inbox.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: emailController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Email',

                labelStyle:
                const TextStyle(
                  color: Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                isLoading
                    ? null
                    : resetPassword,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF6FAA2F,
                  ),

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: isLoading

                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )

                    : const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
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