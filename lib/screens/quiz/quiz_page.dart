import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

import '../../widgets/bottom_nav_bar.dart';

import '../../controllers/quiz_controller.dart';

import '../../services/quiz_service.dart';

import 'take_quiz_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {

  final QuizController _quizController =
  QuizController();

  final QuizService _quizService =
  QuizService();

  List<Map<String, dynamic>> sqliteQuizzes = [];

  bool? _lastEcoMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settings =
    Provider.of<AppSettings>(
      context,
      listen: false,
    );

    // Only run when the mode changes
    if (_lastEcoMode == settings.ecoMode) {
      return;
    }

    _lastEcoMode = settings.ecoMode;

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted) return;

      if (settings.ecoMode) {

        loadSQLiteQuizzes();

      } else {

        syncQuizzesToSQLite();
      }
    });
  }

  // ==================================================
  // NORMAL MODE
  // Firestore → SQLite
  // ==================================================

  Future<void> syncQuizzesToSQLite() async {

    try {

      await _quizController.syncQuizzes();

      final quizzes =
      await _quizService.getQuizzes();

      if (!mounted) return;

      setState(() {
        sqliteQuizzes = quizzes;
      });

    } catch (e) {

      debugPrint(
        'Failed to sync quizzes: $e',
      );
    }
  }

  // ==================================================
  // ECO MODE
  // SQLite only
  // ==================================================

  Future<void> loadSQLiteQuizzes() async {

    try {

      final quizzes =
      await _quizService.getQuizzes();

      if (!mounted) return;

      setState(() {
        sqliteQuizzes = quizzes;
      });

    } catch (e) {

      debugPrint(
        'Failed to load SQLite quizzes: $e',
      );
    }
  }

  // ==================================================
  // PULL TO REFRESH
  //
  // Firestore → SQLite
  // Then upload pending quiz results
  // ==================================================

  Future<void> syncLatestContent() async {

    try {

      debugPrint(
        '==============================',
      );

      debugPrint(
        'REFRESHING QUIZZES',
      );

      debugPrint(
        '==============================',
      );

      // Get latest quizzes from Firestore
      await _quizController.syncQuizzes();

      // Reload SQLite
      final quizzes =
      await _quizService.getQuizzes();

      if (!mounted) return;

      setState(() {
        sqliteQuizzes = quizzes;
      });

      // Upload any unsynchronized quiz results
      await _quizController
          .syncQuizResultsToFirestore();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz synchronized',
          ),
        ),
      );

    } catch (e) {

      debugPrint(
        'Quiz synchronization failed: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Synchronization failed: $e',
          ),
        ),
      );
    }
  }

  // ==================================================
  // NORMAL MODE FIRESTORE QUIZZES
  // ==================================================

  Widget buildFirebaseQuizzes(
      AppSettings settings) {

    return StreamBuilder<QuerySnapshot>(
      stream:
      FirebaseFirestore.instance
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

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Center(
            child:
            CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {

          return Center(
            child: Text(
              'Error loading quizzes',
              style: TextStyle(
                color: AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),
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

        final quizzes =
            snapshot.data!.docs;

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

            return buildQuizCard(
              settings,
              quiz,
              quizzes[index].id,
            );
          },
        );
      },
    );
  }

  // ==================================================
  // ECO MODE SQLITE QUIZZES
  // ==================================================

  Widget buildSQLiteQuizzes(
      AppSettings settings) {

    return RefreshIndicator(
      onRefresh:
      syncLatestContent,

      child: sqliteQuizzes.isEmpty

          ? ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [

          SizedBox(
            height:
            MediaQuery.of(context)
                .size
                .height *
                0.35,
          ),

          Center(
            child: Text(
              'No quizzes available',
              style: TextStyle(
                color:
                AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),
          ),
        ],
      )

          : ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding:
        const EdgeInsets.all(20),

        itemCount:
        sqliteQuizzes.length,

        itemBuilder:
            (context, index) {

          final quiz =
          sqliteQuizzes[index];

          return buildQuizCard(
            settings,
            quiz,
            quiz['id'],
          );
        },
      ),
    );
  }

  // ==================================================
  // QUIZ CARD
  // ==================================================

  Widget buildQuizCard(
      AppSettings settings,
      Map<String, dynamic> quiz,
      String quizId) {

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(20),

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
          const BoxShadow(
            color:
            Colors.black12,
            blurRadius:
            10,
            offset:
            Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Container(
                width: 50,
                height: 50,

                decoration:
                BoxDecoration(
                  color:
                  AppColors
                      .primaryLight(
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
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      quiz['title'] ?? '',

                      style:
                      TextStyle(
                        color:
                        AppColors.text(
                          settings.darkTheme,
                        ),

                        fontWeight:
                        FontWeight.bold,

                        fontSize:
                        18,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      quiz['description'] ?? '',

                      style:
                      TextStyle(
                        color:
                        AppColors
                            .subText(
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
                          quizId,
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
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(
      BuildContext context) {

    final settings =
    Provider.of<AppSettings>(
      context,
    );

    return Scaffold(
      backgroundColor:
      AppColors.background(
        settings.darkTheme,
      ),

      appBar:
      AppBar(
        backgroundColor:
        AppColors.background(
          settings.darkTheme,
        ),

        elevation: 0,

        title:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Text(
              'Quiz',

              style:
              TextStyle(
                color:
                AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),

            Text(
              settings.ecoMode
                  ? 'ECO MODE'
                  : 'NORMAL MODE',

              style:
              TextStyle(
                fontSize:
                12,

                fontWeight:
                FontWeight.bold,

                color:
                settings.ecoMode
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),

        iconTheme:
        IconThemeData(
          color:
          AppColors.text(
            settings.darkTheme,
          ),
        ),
      ),

      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),

      body:
      settings.ecoMode

          ? buildSQLiteQuizzes(
        settings,
      )

          : buildFirebaseQuizzes(
        settings,
      ),
    );
  }
}