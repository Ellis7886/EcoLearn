import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/setting_switch.dart';

import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  bool ecoMode = true;
  bool darkTheme = true;

  late Future<DocumentSnapshot> userFuture;

  @override
  void initState() {
    super.initState();

    final currentUser =
        FirebaseAuth.instance.currentUser;

    userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
  }

  Widget buildStatCard(
      String title,
      String value,
      IconData icon,
      ) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF9BD028),
            size: 35,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: userFuture,

        builder: (context, snapshot) {

          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(!snapshot.hasData ||
              !snapshot.data!.exists){

            return const Center(
              child: Text(
                'User data not found',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final user = UserModel.fromFirestore(
            snapshot.data!.data()
            as Map<String, dynamic>,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius:
                      BorderRadius.circular(25),
                    ),

                    child: Column(
                      children: [

                        const CircleAvatar(
                          radius: 55,
                          backgroundColor:
                          Color(0xFF9BD028),

                          child: Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF9BD028),
                            borderRadius:
                            BorderRadius.circular(30),
                          ),

                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Learning Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: buildStatCard(
                          'Lessons',
                          '12',
                          Icons.menu_book,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: buildStatCard(
                          'Quiz',
                          '85%',
                          Icons.quiz,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const SettingSwitch(
                    title: 'EcoMode',
                    description: 'Optimize performance and save energy',
                    icon: Icons.eco,
                  ),

                  const SettingSwitch(
                    title: 'Dark Theme',
                    description: 'Reduce brightness for better comfort',
                    icon: Icons.dark_mode,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {

                        await FirebaseAuth.instance
                            .signOut();

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
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 15,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'EcoLearn v1.0.0',
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}