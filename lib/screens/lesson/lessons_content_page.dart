import 'package:ecolearn/widgets/chapter_card_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/performance_logger.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/chapter_card.dart';
import '../../controllers/chapter_controller.dart';
import '../../controllers/material_controller.dart';

class LessonsContentPage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String lessonCode;

  const LessonsContentPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonCode,
  });

  @override
  State<LessonsContentPage> createState() => _LessonsContentPageState();
}

class _LessonsContentPageState extends State<LessonsContentPage>{
  final ChapterController _chapterController = ChapterController();
  final MaterialController _materialController = MaterialController();

  int refreshCounter = 0;
  List<Map<String, dynamic>> sqliteChapters = [];
  bool? _lastEcoMode;

  // CHANGED: created once, not inside build()
  Stream<QuerySnapshot>? _chaptersStream;

  PerfSession? _loadSession;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settings = Provider.of<AppSettings>(
      context,
      listen: false,
    );

    if (_lastEcoMode == settings.ecoMode) {
      return;
    }

    _lastEcoMode = settings.ecoMode;

    if (settings.ecoMode) {
      _chaptersStream = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        loadSQLiteChapters();
      });
    } else {
      // CHANGED: Normal Mode only uses the live Firestore
      // listener (no extra copy into SQLite, no extra
      // per-chapter material queries).
      PerformanceLogger.start().then((session) {
        _loadSession = session;
      });

      _chaptersStream = FirebaseFirestore.instance
          .collection('chapters')
          .where('lesson_id', isEqualTo: widget.lessonId)
          .snapshots();
    }
  }

  void _finishNormalTiming(QuerySnapshot snapshot) {
    final session = _loadSession;
    if (session == null) return;
    _loadSession = null;

    PerformanceLogger.finish(
      session,
      mode: 'Normal',
      operation: 'Load Chapters',
      dataSource: snapshot.metadata.isFromCache
          ? 'Firestore (cache)'
          : 'Firestore (server)',
      recordCount: snapshot.docs.length,
    );
  }

  /// Eco Mode: Firestore -> SQLite for the chapters of this
  /// lesson and ALL their materials (few whereIn queries
  /// instead of one query per chapter).
  Future<List<Map<String, dynamic>>> _syncChaptersAndMaterials() async {
    final chapters =
    await _chapterController.syncChapters(widget.lessonId);

    await _materialController.syncMaterialsForChapters(
      chapters.map((c) => c['id'].toString()).toList(),
    );

    return chapters;
  }

  Future<void> loadSQLiteChapters() async {

    final session = await PerformanceLogger.start();

    var chapters =
    await _chapterController.getSQLiteChapters(widget.lessonId);

    var source = 'SQLite';

    // NEW: first visit in Eco Mode -> sync once
    if (chapters.isEmpty) {
      try {
        chapters = await _syncChaptersAndMaterials();
        source = 'Firestore->SQLite (first sync)';
      } catch (e) {
        debugPrint('ECO MODE: chapter sync failed: $e');
      }
    }

    await PerformanceLogger.finish(
      session,
      mode: 'Eco',
      operation: 'Load Chapters',
      dataSource: source,
      recordCount: chapters.length,
    );

    if (!mounted) return;

    setState(() {
      sqliteChapters = chapters;
    });
  }

  // Eco Mode pull-to-refresh
  Future<void> syncLatestContent() async {

    try {
      final session = await PerformanceLogger.start();

      final chapters = await _syncChaptersAndMaterials();

      await PerformanceLogger.finish(
        session,
        mode: 'Eco',
        operation: 'Refresh Chapters',
        dataSource: 'Firestore->SQLite',
        recordCount: chapters.length,
      );

      if (!mounted) return;

      setState(() {
        sqliteChapters = chapters;
        refreshCounter++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Content updated"),
        ),
      );
    } catch (e) {
      debugPrint('Failed to refresh chapters: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not update. Showing saved content."),
        ),
      );
    }
  }

  Widget buildFirebaseChapters(AppSettings settings) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chaptersStream,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());

          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No chapters available.",
              style: TextStyle(
                color: AppColors.text(settings.darkTheme),
              ),
            ),
          );
        }

        final chapters = snapshot.data!.docs;

        if (_loadSession != null) {
          final data = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _finishNormalTiming(data);
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: chapters.length,
          itemBuilder: (context, index) {

            final chapter = chapters[index];

            return ChapterCard(
              chapter: chapter,
              lessonId: widget.lessonId,
              darkTheme: settings.darkTheme,
            );
          },
        );
      },
    );
  }

  Widget buildSQLiteChapters(AppSettings settings) {
    return RefreshIndicator(
      onRefresh: syncLatestContent,

      child: sqliteChapters.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height * 0.35,
          ),

          Center(
            child: Text(
              "No chapters available.",
              style: TextStyle(
                color: AppColors.text(
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

        padding: const EdgeInsets.all(20),

        itemCount: sqliteChapters.length,

        itemBuilder: (context, index) {
          final chapter =
          sqliteChapters[index];

          return ChapterCardSqlite(
            chapter: chapter,
            lessonId: widget.lessonId,
            darkTheme: settings.darkTheme,
            refreshCounter: refreshCounter,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(settings.darkTheme),

      appBar: AppBar(
        backgroundColor: AppColors.background(settings.darkTheme),
        iconTheme: IconThemeData(
          color: AppColors.text(settings.darkTheme),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lessonTitle,
              style: TextStyle(
                color: AppColors.text(settings.darkTheme),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.lessonCode,
              style: TextStyle(
                color: AppColors.text(settings.darkTheme),
                fontSize: 12,
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

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),

      body: settings.ecoMode
          ? buildSQLiteChapters(settings)
          : buildFirebaseChapters(settings),
    );
  }
}