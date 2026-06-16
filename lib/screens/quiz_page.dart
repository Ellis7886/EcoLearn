import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/bottom_nav_bar.dart';
import 'create_quiz_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {

  String role = '';

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final doc =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (mounted) {
      setState(() {
        role = doc['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      floatingActionButton:
      role == 'lecturer'
          ? FloatingActionButton(
        backgroundColor:
        const Color(0xFF9BD028),

        onPressed: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
              const CreateQuizPage(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      )
          : null,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          'Quiz',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {},
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .orderBy(
          'created_at',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                'No quizzes available',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final quizzes =
              snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: quizzes.length,

            itemBuilder: (context, index) {

              final quiz = quizzes[index];

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color:
                  const Color(0xFF2B2B2B),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: ListTile(

                  leading: const Icon(
                    Icons.quiz,
                    color: Color(0xFF9BD028),
                    size: 35,
                  ),

                  title: Text(
                    quiz['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        quiz['description'] ?? '',
                        style: const TextStyle(
                          color:
                          Colors.white70,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        'Tap to view quiz',
                        style: TextStyle(
                          color: Color(0xFF9BD028),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),

                  onTap: () {

                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(

                      SnackBar(
                        content: Text(
                          'Open ${quiz['title']}',
                        ),
                      ),
                    );

                    // Later:
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //     QuizAttemptPage(
                    //       quizId: quiz.id,
                    //     ),
                    //   ),
                    // );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}