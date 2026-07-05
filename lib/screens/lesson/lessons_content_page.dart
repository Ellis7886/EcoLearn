import 'package:ecolearn/screens/lesson/create_content_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      backgroundColor: AppColors.background(settings.darkTheme,),

      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final role = snapshot.data!['role'];

          if (role != 'lecturer') {
            return const SizedBox();
          }

          return FloatingActionButton(
            backgroundColor: AppColors.primary,

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateContentPage(
                    lessonId: lessonId,
                    lessonTitle: lessonTitle,
                    lessonCode: lessonCode,
                  ),
                ),
              );
            },

            child: const Icon(
              Icons.upload_file,
              color: Colors.black,
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background(settings.darkTheme,),

        title: Text(
          lessonTitle,
          style: TextStyle(
            color: AppColors.text(settings.darkTheme,),
          ),
        ),

        iconTheme: IconThemeData(
          color: AppColors.text(settings.darkTheme,),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content')
            .where('type', isEqualTo: 'chapter',)
            .where('lesson_id', isEqualTo: lessonId,)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No chapters available',
                style: TextStyle(
                  color: AppColors.text(
                    settings.darkTheme,
                  ),
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
                darkTheme: settings.darkTheme,
                lessonId: lessonId,
              );
            },
          );
        },
      ),
    );
  }
}