import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/chapter_card.dart';

class LessonsContentPage extends StatelessWidget {
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
              lessonTitle,
              style: TextStyle(
                color: AppColors.text(settings.darkTheme),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              lessonCode,
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chapters')
            .where('lesson_id', isEqualTo: lessonId)
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
                lessonId: lessonId,
                darkTheme: settings.darkTheme,
              );
            },
          );
        },
      ),
    );
  }
}