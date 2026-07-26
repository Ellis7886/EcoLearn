import 'package:ecolearn/widgets/chapter_card_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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

  @override void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final settings = Provider.of<AppSettings>(context, listen: false);

      if (settings.ecoMode) {
        loadSQLiteChapters();
      } else {
        syncChaptersToSQLite();
      }

    });
  }

  Future<void> syncChaptersToSQLite() async {

    // Sync chapters first
    final chapters = await _chapterController.syncChapters(widget.lessonId);

    // Sync materials for every chapter
    for (final chapter in chapters) {
      await _materialController.syncMaterials(chapter['id']);
    }

    if (!mounted) return;

    setState(() {
      sqliteChapters = chapters;
    });
  }

  Future<void> loadSQLiteChapters() async {

    final chapters =
    await _chapterController.getSQLiteChapters(widget.lessonId);

    if (!mounted) return;

    setState(() {
      sqliteChapters = chapters;
    });
  }

  Future<void> syncLatestContent() async {

    await syncChaptersToSQLite();

    if (!mounted) return;

    setState(() {
      refreshCounter++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Content updated"),
      ),
    );
  }

  Widget buildFirebaseChapters(AppSettings settings) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chapters')
          .where('lesson_id', isEqualTo: widget.lessonId)
          .snapshots(),
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

    if (sqliteChapters.isEmpty) {
      return Center(
        child: Text(
          "No chapters available.",
          style: TextStyle(
            color: AppColors.text(settings.darkTheme),
          ),
        ),
      );
    }

    return RefreshIndicator(

      onRefresh: syncLatestContent,

      child: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: sqliteChapters.length,

        itemBuilder: (context, index) {

          final chapter = sqliteChapters[index];

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