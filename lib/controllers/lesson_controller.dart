import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/lesson_service.dart';

class LessonController {

  Future<String> getUserRole() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return doc['role'];
  }

  Future<List<Map<String, dynamic>>> getSQLiteLessons()
  async {

    final lessonService = LessonService();

    return await lessonService.getLessons();
  }

  Future<List<Map<String, dynamic>>> syncLessons() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .get();

    final lessonService = LessonService();

    await lessonService.clearLessons();

    for (var doc in snapshot.docs) {
      final lesson = doc.data();
      await lessonService.insertLesson({
        'id': doc.id,
        'title': lesson['title'],
        'description': lesson['description'],
        'course_code': lesson['course_code'],
        'progress': lesson['progress'],
      });
    }

    return await lessonService.getLessons();
  }
}