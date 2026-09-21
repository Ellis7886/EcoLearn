import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../controllers/lesson_controller.dart';

import '../../themes/app_colors.dart';

import '../../provider/app_settings.dart';

import '../../widgets/lesson_card.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../services/performance_logger.dart';

import 'lessons_content_page.dart';


class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final LessonController _lessonController = LessonController();

  List<Map<String, dynamic>> sqliteLessons = [];
  bool? _lastEcoMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settings =
    Provider.of<AppSettings>(
      context,
      listen: false,
    );

    if (_lastEcoMode == settings.ecoMode) {
      return;
    }

    _lastEcoMode = settings.ecoMode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (settings.ecoMode) {
        initializeEcoMode();
      } else {
        syncLessonsToSQLite();
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
      operation: 'Load Lessons',
      dataSource: 'Firestore',
      recordCount: lessons.length,
      loadTime: stopwatch.elapsedMilliseconds,
    );
  }

  Future<List<Map<String, dynamic>>> loadSQLiteLessons() async {

    final stopwatch = Stopwatch()..start();

    final lessons =
    await _lessonController.getSQLiteLessons();

    stopwatch.stop();

    if (!mounted) {
      return lessons;
    }

    setState(() {
      sqliteLessons = lessons;
    });

    await PerformanceLogger.log(
      mode: 'Eco',
      operation: 'Load Lessons',
      dataSource: 'SQLite',
      recordCount: lessons.length,
      loadTime: stopwatch.elapsedMilliseconds,
    );

    return lessons;
  }

  Future<void> syncLatestContent() async {

    try {

      debugPrint('==============================');
      debugPrint('REFRESHING LESSON CONTENT');
      debugPrint('==============================');

      // Check Firestore and synchronize
      // the latest lessons into SQLite.
      final lessons =
      await _lessonController.syncLessons();

      if (!mounted) return;

      // Update the screen using the
      // newly synchronized SQLite data.
      setState(() {
        sqliteLessons = lessons;
      });

      debugPrint(
        'Lessons updated: ${lessons.length}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lessons updated',
          ),
        ),
      );

    } catch (e) {

      debugPrint(
        'Failed to refresh lessons: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update lessons: $e',
          ),
        ),
      );
    }
  }

  Future<void> initializeEcoMode() async {

    final lessons =
    await _lessonController.getSQLiteLessons();

    if (!mounted) return;

    if (lessons.isEmpty) {

      debugPrint(
        'ECO MODE: SQLite is empty. Performing initial sync...',
      );

      await syncLessonsToSQLite();

    } else {

      debugPrint(
        'ECO MODE: SQLite already contains ${lessons.length} lessons.',
      );

      setState(() {
        sqliteLessons = lessons;
      });
    }
  }

  Widget buildSQLiteLessons(AppSettings settings) {
    return RefreshIndicator(
      onRefresh: syncLatestContent,

      child: sqliteLessons.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
          ),

          Center(
            child: Text(
              'No lessons found',
              style: TextStyle(
                color: AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),
          ),
        ],
      ) : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

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

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lessons',
              style: TextStyle(
                color: AppColors.text(
                  settings.darkTheme,
                ),
              ),
            ),

            Text(
              settings.ecoMode
                  ? 'ECO MODE'
                  : 'NORMAL MODE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: settings.ecoMode
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ),

      body: settings.ecoMode
          ? buildSQLiteLessons(settings)
          : buildFirebaseLessons(settings),
    );
  }
}