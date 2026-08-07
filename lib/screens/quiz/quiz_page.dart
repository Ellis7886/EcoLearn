import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

import '../../widgets/bottom_nav_bar.dart';

import '../../controllers/quiz_controller.dart';

import 'take_quiz_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {

  final QuizController _quizController = QuizController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final settings = Provider.of<AppSettings>(
        context,
        listen: false,
      );

      if (!settings.ecoMode) {
        syncQuizzesToSQLite();
      }
    });
  }

  Future<void> syncQuizzesToSQLite() async {

    await _quizController.syncQuizzes();

  }

  Future<void> syncLatestContent() async {

    // Download latest quizzes
    await syncQuizzesToSQLite();

    // Upload local quiz results
    await _quizController.syncQuizResultsToFirestore();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Quiz synchronized',
        ),
      ),
    );
  }

  Future<void> deleteQuiz(
      String quizId) async {

    try {

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .delete();

      await syncQuizzesToSQLite();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz deleted successfully',
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    }
  }

  Future<void> confirmDeleteQuiz(
      String quizId) async {

    final confirm =
    await showDialog<bool>(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Quiz',
        ),

        content: const Text(
          'Are you sure you want to delete this quiz?',
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Cancel',
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteQuiz(quizId);
    }
  }

  @override
  Widget build(BuildContext context) {

    final settings =
    Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor:
      AppColors.background(
        settings.darkTheme,
      ),

      appBar: AppBar(
        backgroundColor:
        AppColors.background(
          settings.darkTheme,
        ),

        elevation: 0,

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

      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),

        body: RefreshIndicator(onRefresh: syncLatestContent, child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quizzes')
              .orderBy(
            'created_at',
            descending: true,
          )
              .snapshots(),

          builder: (
              context,
              snapshot,
              ) {

            if (snapshot.connectionState == ConnectionState.waiting) {

              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {

              return Center(
                child: Text(
                  'No quizzes available',
                  style: TextStyle(
                    color:
                    AppColors.text(
                      settings.darkTheme,
                    ),
                  ),
                ),
              );
            }

            final quizzes = snapshot.data!.docs;

            return ListView.builder(
              padding:
              const EdgeInsets.all(20),

              itemCount:
              quizzes.length,

              itemBuilder:
                  (context, index) {

                final quiz =
                quizzes[index].data()
                as Map<String, dynamic>;

                return Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 15,
                  ),

                  padding:
                  const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.card(
                      settings.darkTheme,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    boxShadow:
                    settings.darkTheme
                        ? []
                        : [
                      BoxShadow(
                        color:
                        Colors.black12,
                        blurRadius:
                        10,
                        offset:
                        const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Row(
                        children: [

                          Container(
                            width: 50,
                            height: 50,

                            decoration:
                            BoxDecoration(
                              color:
                              AppColors.primaryLight(
                                settings.darkTheme,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                            child:
                            const Icon(
                              Icons.quiz,
                              color:
                              AppColors.primary,
                            ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  quiz['title'] ?? '',
                                  style: TextStyle(
                                    color: AppColors.text(
                                      settings.darkTheme,
                                    ),
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  quiz['description'] ?? '',
                                  style: TextStyle(
                                    color: AppColors.subText(
                                      settings.darkTheme,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TakeQuizPage(
                                      quizId:
                                      quizzes[index].id,
                                    ),
                              ),
                            );
                          },

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            AppColors.primary,
                          ),

                          child:
                          const Text(
                            'START QUIZ',

                            style:
                            TextStyle(
                              color:
                              Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}