import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../controllers/lesson_controller.dart';
import '../../controllers/material_controller.dart';

import '../../themes/app_colors.dart';

import '../../provider/app_settings.dart';

import '../../widgets/lesson_card.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../services/performance_logger.dart';

import 'lessons_content_page.dart';
// import 'edit_lesson_page.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final LessonController _lessonController = LessonController();
  final MaterialController _materialController = MaterialController();

  List<Map<String, dynamic>> sqliteLessons = [];

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      final settings =
      Provider.of<AppSettings>(context, listen: false);

      if (settings.ecoMode) {

        loadSQLiteLessons();

      } else {

        syncLessonsToSQLite();
        syncMaterialsToSQLite();

        FirebaseFirestore.instance
            .collection('lessons')
            .snapshots()
            .listen((_) {

          syncLessonsToSQLite();

        });
      }
    });
  }

  Future<void> syncLessonsToSQLite() async {
    final stopwatch = Stopwatch()..start();

    final lessons = await _lessonController.syncLessons();

    setState(() {
      sqliteLessons = lessons;
    });

    stopwatch.stop();

    await PerformanceLogger.log(
      mode: 'Normal',
      operation: 'Firebase Sync',
      recordCount: lessons.length,
      loadTime: stopwatch.elapsedMilliseconds,
    );
  }

  Future<void> loadSQLiteLessons() async {

    final stopwatch = Stopwatch()..start();

    final lessons = await _lessonController.getSQLiteLessons();

    setState(() {
      sqliteLessons = lessons;
    });

    stopwatch.stop();

    await PerformanceLogger.log(
      mode: 'Eco',
      operation: 'SQLite Read',
      recordCount: lessons.length,
      loadTime: stopwatch.elapsedMilliseconds,
    );
  }

  Future<void> syncMaterialsToSQLite() async {

    await _materialController.syncMaterials();

    print('Materials synced');
  }

  Future<void> refreshLessons() async {

    await syncLessonsToSQLite();

    await syncMaterialsToSQLite();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Content updated',
        ),
      ),
    );
  }

  Widget buildSQLiteLessons(AppSettings settings) {

    if (sqliteLessons.isEmpty) {
      return Center(
        child: Text(
          'No lessons found',
          style: TextStyle(
            color: AppColors.text(settings.darkTheme),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshLessons,

      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sqliteLessons.length,

        itemBuilder: (context, index) {

          final lesson = sqliteLessons[index];

          return LessonCard(
            title: lesson['title'],
            description: lesson['description'],
            courseCode: lesson['course_code'],
            progress:
            (lesson['progress'] ?? 0) / 100,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LessonsContentPage(
                        lessonId:
                        lesson['id'],
                        lessonTitle:
                        lesson['title'],
                        lessonCode:
                        lesson['course_code'],
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildFirebaseLessons(AppSettings settings) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lessons')
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

          return Center(
            child: Text(
              'No lessons found',
              style: TextStyle(
                color: AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),
          );
        }

        final lessons = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: lessons.length,

          itemBuilder: (context, index) {

            final lesson = lessons[index].data()
            as Map<String, dynamic>;

            return LessonCard(
              title: lesson['title'],
              description: lesson['description'],
              courseCode: lesson['course_code'],
              progress: lesson['progress'] / 100,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonsContentPage(
                      lessonId: lessons[index].id,
                      lessonTitle: lesson['title'],
                      lessonCode: lesson['course_code'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(settings.darkTheme,),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background(
          settings.darkTheme,
        ),
        elevation: 0,

        iconTheme: IconThemeData(
          color: AppColors.text(
            settings.darkTheme,
          ),
        ),

        title: Text(
          'Lessons',
          style: TextStyle(
            color: AppColors.text(
              settings.darkTheme,
            ),
          ),
        ),
      ),

      body: settings.ecoMode
          ? buildSQLiteLessons(settings)
          : buildFirebaseLessons(settings),
    );
  }
}