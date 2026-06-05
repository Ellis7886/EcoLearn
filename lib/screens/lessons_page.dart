import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';

import '../provider/app_settings.dart';

import '../widgets/lesson_card.dart';
import '../widgets/bottom_nav_bar.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(
        settings.darkTheme,
      ),

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

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('lessons')
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

              final lesson = lessons[index].data();

              return LessonCard(
                title: lesson['title'],
                description: lesson['description'],
                courseCode: lesson['course_code'],
                progress: lesson['progress']/100,
              );
            },
          );
        },
      ),
    );
  }
}