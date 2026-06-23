import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLessonPage extends StatefulWidget {

  final String lessonId;
  final String title;
  final String description;
  final String courseCode;

  const EditLessonPage({
    super.key,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.courseCode,
  });

  @override
  State<EditLessonPage> createState() =>
      _EditLessonPageState();
}

class _EditLessonPageState
    extends State<EditLessonPage> {

  late TextEditingController
  courseCodeController;

  late TextEditingController
  courseTitleController;

  late TextEditingController
  descriptionController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    courseCodeController =
        TextEditingController(
          text: widget.courseCode,
        );

    courseTitleController =
        TextEditingController(
          text: widget.title,
        );

    descriptionController =
        TextEditingController(
          text: widget.description,
        );
  }

  Future<void> updateLesson() async {

    if (courseCodeController.text
        .trim()
        .isEmpty ||
        courseTitleController.text
            .trim()
            .isEmpty ||
        descriptionController.text
            .trim()
            .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          .doc(widget.lessonId)
          .update({

        'course_code':
        courseCodeController.text.trim(),

        'title':
        courseTitleController.text.trim(),

        'description':
        descriptionController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Lesson updated successfully',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          'Edit Lesson',
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
              controller:
              courseCodeController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText:
                'Course Code',

                labelStyle:
                const TextStyle(
                  color:
                  Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
              courseTitleController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText:
                'Course Title',

                labelStyle:
                const TextStyle(
                  color:
                  Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
              descriptionController,

              maxLines: 4,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText:
                'Description',

                labelStyle:
                const TextStyle(
                  color:
                  Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
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

              child:
              ElevatedButton(

                onPressed:
                isSaving
                    ? null
                    : updateLesson,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF9BD028,
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 15,
                  ),
                ),

                child: isSaving

                    ? const CircularProgressIndicator(
                  color:
                  Colors.black,
                )

                    : const Text(
                  'UPDATE LESSON',

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