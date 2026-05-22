import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/bottom_nav_bar.dart';

import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),

        builder: (context, snapshot) {

          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(!snapshot.hasData || !snapshot.data!.exists){

            return const Center(
              child: Text(
                'User data not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userData =
          snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const SizedBox(height: 30),

                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF9BD028),

                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  userData['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  userData['email'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF9BD028),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    userData['role'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Column(
                    children: [

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          Text(
                            'Eco Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),

                          Icon(
                            Icons.eco,
                            color: Color(0xFF9BD028),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          Text(
                            'Dark Theme',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),

                          Icon(
                            Icons.dark_mode,
                            color: Color(0xFF9BD028),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () async {

                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const LoginPage(),
                        ),

                            (route) => false,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),

                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}