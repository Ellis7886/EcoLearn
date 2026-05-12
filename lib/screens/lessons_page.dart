import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/lesson_card.dart';
import '../widgets/bottom_nav_bar.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Lessons',
          style: TextStyle(color: Colors.white),
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

            return const Center(
              child: Text(
                'No lessons found',
                style: TextStyle(color: Colors.white),
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