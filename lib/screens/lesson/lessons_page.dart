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

  // CHANGED: the Firestore stream is created ONCE and reused.
  // Creating it inside build() opened a new listener on every
  // rebuild.
  Stream<QuerySnapshot>? _lessonsStream;

  // Measures "screen opened -> lessons shown" in BOTH modes,
  // so the two modes are timed the same way.
  PerfSession? _loadSession;

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

    if (settings.ecoMode) {
      // Eco Mode: no Firestore listener at all
      _lessonsStream = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        initializeEcoMode();
      });
    } else {
      // CHANGED: Normal Mode ONLY uses the live Firestore
      // listener. It no longer also copies everything into
      // SQLite (that downloaded the same data twice and made
      // Normal Mode look worse than it really is).
      PerformanceLogger.start().then((session) {
        _loadSession = session;
      });

      _lessonsStream = FirebaseFirestore.instance
          .collection('lessons')
          .orderBy(
        'created_at',
        descending: true,
      )
          .snapshots();
    }
  }

  // Called once, when the first Normal Mode snapshot arrives
  void _finishNormalTiming(QuerySnapshot snapshot) {
    final session = _loadSession;
    if (session == null) return;
    _loadSession = null;

    PerformanceLogger.finish(
      session,
      mode: 'Normal',
      operation: 'Load Lessons',
      dataSource: snapshot.metadata.isFromCache
          ? 'Firestore (cache)'
          : 'Firestore (server)',
      recordCount: snapshot.docs.length,
    );
  }

  Future<void> initializeEcoMode() async {

    final session = await PerformanceLogger.start();

    var lessons =
    await _lessonController.getSQLiteLessons();

    var source = 'SQLite';

    if (lessons.isEmpty) {

      debugPrint(
        'ECO MODE: SQLite is empty. Performing initial sync...',
      );

      try {
        lessons = await _lessonController.syncLessons();
        source = 'Firestore->SQLite (first sync)';
      } catch (e) {
        debugPrint('ECO MODE: initial sync failed: $e');
      }
    }

    await PerformanceLogger.finish(
      session,
      mode: 'Eco',
      operation: 'Load Lessons',
      dataSource: source,
      recordCount: lessons.length,
    );

    if (!mounted) return;

    setState(() {
      sqliteLessons = lessons;
    });
  }

  // Eco Mode pull-to-refresh
  Future<void> syncLatestContent() async {

    try {

      final session = await PerformanceLogger.start();

      final lessons =
      await _lessonController.syncLessons();

      await PerformanceLogger.finish(
        session,
        mode: 'Eco',
        operation: 'Refresh Lessons',
        dataSource: 'Firestore->SQLite',
        recordCount: lessons.length,
      );

      if (!mounted) return;

      setState(() {
        sqliteLessons = lessons;
      });

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
        const SnackBar(
          content: Text(
            'Could not update lessons. Showing saved lessons.',
          ),
        ),
      );
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
      stream: _lessonsStream,

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

        if (_loadSession != null) {
          final data = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _finishNormalTiming(data);
          });
        }

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
              progress: ((lesson['progress'] ?? 0) as num) / 100,

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