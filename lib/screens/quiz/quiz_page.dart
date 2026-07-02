import 'package:ecolearn/screens/quiz/create_quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';

import '../../themes/app_colors.dart';

import '../../widgets/bottom_nav_bar.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key,});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(
        settings.darkTheme,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background(
          settings.darkTheme,
        ),

        title: Text(
          'Quiz',
          style: TextStyle(
            color: AppColors.text(
              settings.darkTheme,
            ),
          ),
        ),

        iconTheme: IconThemeData(
          color: AppColors.text(
            settings.darkTheme,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('quizzes')
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

            return Center(
              child: Text(
                'No quizzes available',
                style: TextStyle(
                  color: AppColors.text(
                    settings.darkTheme,
                  ),
                ),
              ),
            );
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: quizzes.length,

            itemBuilder: (context, index) {

              final quiz = quizzes[index];

              final title =
                  quiz['title'] ?? '';

              final totalQuestions =
                  quiz['total_questions'] ?? 0;

              final passingMarks =
                  quiz['passing_marks'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color: AppColors.card(settings.darkTheme,),

                  borderRadius: BorderRadius.circular(20,),
                ),

                child: Padding(
                  padding:
                  const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          Container(
                            padding:
                            const EdgeInsets.all(
                              12,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFF9BD028,
                              ).withValues(
                                alpha: 0.15,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                            child: const Icon(
                              Icons.quiz,
                              color: Color(
                                0xFF9BD028,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Text(
                              title,

                              style: TextStyle(
                                color: AppColors.text(
                                  settings.darkTheme,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        '$totalQuestions Questions',

                        style:
                        TextStyle(
                          color: AppColors.subText(
                            settings.darkTheme,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Passing Marks: $passingMarks',

                        style:
                        TextStyle(
                          color: AppColors.subText(
                            settings.darkTheme,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        ElevatedButton(

                          onPressed: () {

                            // Navigate to
                            // TakeQuizPage

                          },

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF9BD028,
                            ),
                          ),

                          child: const Text(
                            'START QUIZ',

                            style: TextStyle(
                              color:
                              Colors.black,

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
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final role = snapshot.data!['role'] ?? 'student';

          if (role != 'lecturer') {
            return const SizedBox();
          }

          return FloatingActionButton(
            backgroundColor: AppColors.primary,

            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateQuizPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}