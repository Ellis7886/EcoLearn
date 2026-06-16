import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateLessonPage extends StatefulWidget {
  const CreateLessonPage({super.key});

  @override
  State<CreateLessonPage> createState() => _CreateLessonPageState();
}

class _CreateLessonPageState extends State<CreateLessonPage> {

  final courseCodeController = TextEditingController();

  final courseTitleController = TextEditingController();

  final descriptionController = TextEditingController();

  bool isSaving = false;

  Future<void> createLesson() async {

    if (courseCodeController.text.trim().isEmpty ||
        courseTitleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('lessons')
          .add({

        'course_code': courseCodeController.text.trim(),

        'title': courseTitleController.text.trim(),

        'description': descriptionController.text.trim(),

        'progress': 0,

        'created_at': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lesson created successfully',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          'Create Lesson',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme:
        const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: courseCodeController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Course Code',

                labelStyle: const TextStyle(
                  color: Colors.white70,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller: courseTitleController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Course Title',

                labelStyle: const TextStyle(
                  color: Colors.white70,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller: descriptionController,

              maxLines: 4,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Description',

                labelStyle: const TextStyle(
                  color: Colors.white70,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: isSaving ? null : createLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9BD028,),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: isSaving ? const CircularProgressIndicator(
                  color: Colors.black,
                ) : const Text(
                  'CREATE LESSON',
                  style: TextStyle(
                    color:
                    Colors.black,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}