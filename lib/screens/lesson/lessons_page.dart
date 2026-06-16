import 'package:ecolearn/screens/lesson/create_lesson_page.dart';

import 'lessons_materials_page.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../themes/app_colors.dart';

import '../../provider/app_settings.dart';

import '../../widgets/lesson_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {

  String role = '';

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      role = doc['role'];
    });
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(settings.darkTheme,),

      floatingActionButton:
      role == 'lecturer' ? FloatingActionButton(
        backgroundColor:
        const Color(0xFF9BD028),

        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const CreateLessonPage(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ) : null,

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

          if (snapshot.connectionState == ConnectionState.waiting) {

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
                progress: lesson['progress'] / 100,

                onTap: () {

                  Navigator.push(context,

                    MaterialPageRoute(
                      builder: (context) => MaterialsPage(
                        lessonId: lessons[index].id,
                        lessonTitle: lesson['title'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}