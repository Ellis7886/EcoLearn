import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'loading_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  String selectedRole = 'student';

  Future<void> register() async {

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields',
          ),
        ),
      );

      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingPage();
      },
    );

    try {

      UserCredential credential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email:
        emailController.text.trim(),
        password:
        passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({

        'name':
        nameController.text.trim(),

        'email':
        emailController.text.trim(),

        'role':
        selectedRole,

        'createdAt':
        Timestamp.now(),
      });

      if(!mounted) return;

      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Registration Successful',
          ),
        ),
      );
    }
    on FirebaseAuthException catch (e) {

      navigator.pop();

      String message =
          'Registration Failed';

      if (e.code ==
          'email-already-in-use') {

        message =
        'Email already exists';
      }
      else if (e.code ==
          'invalid-email') {

        message =
        'Invalid email format';
      }
      else if (e.code ==
          'weak-password') {

        message =
        'Password is too weak';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        iconTheme:
        const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 10),

            Image.asset(
              'assets/images/ecolearn_logo.png',
              height: 150,
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
              nameController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                hintText:
                'Full Name',

                hintStyle:
                const TextStyle(
                  color:
                  Colors.white54,
                ),

                filled: true,

                fillColor:
                const Color(
                    0xFF2B2B2B),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                      15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              emailController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                hintText: 'Email',

                hintStyle:
                const TextStyle(
                  color:
                  Colors.white54,
                ),

                filled: true,

                fillColor:
                const Color(
                    0xFF2B2B2B),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                      15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              passwordController,

              obscureText: true,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                hintText:
                'Password',

                hintStyle:
                const TextStyle(
                  color:
                  Colors.white54,
                ),

                filled: true,

                fillColor:
                const Color(
                    0xFF2B2B2B),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                      15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              confirmPasswordController,

              obscureText: true,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                hintText:
                'Confirm Password',

                hintStyle:
                const TextStyle(
                  color:
                  Colors.white54,
                ),

                filled: true,

                fillColor:
                const Color(
                    0xFF2B2B2B),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                      15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<
                String>(
              initialValue: selectedRole,

              dropdownColor:
              const Color(
                  0xFF2B2B2B),

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              InputDecoration(
                filled: true,

                fillColor:
                const Color(
                    0xFF2B2B2B),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                      15),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value:
                  'student',

                  child:
                  Text('Student'),
                ),

                DropdownMenuItem(
                  value:
                  'lecturer',

                  child:
                  Text('Lecturer'),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  selectedRole =
                  value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
              double.infinity,

              child: ElevatedButton(
                onPressed:
                register,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                      0xFF9BD028),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 15,
                  ),
                ),

                child:
                const Text(
                  'Register',

                  style:
                  TextStyle(
                    color:
                    Colors.black,

                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,

              children: [

                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color:
                    Colors.white70,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                        context);
                  },

                  child:
                  const Text(
                    'Login',

                    style:
                    TextStyle(
                      color: Color(
                          0xFF9BD028),

                      fontWeight:
                      FontWeight
                          .bold,
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