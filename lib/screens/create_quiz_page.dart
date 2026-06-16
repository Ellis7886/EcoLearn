import 'package:ecolearn/screens/manage_questions_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() =>
      _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isSaving = false;

  Future<void> saveQuiz() async {

    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {

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

      final docRef = await FirebaseFirestore.instance
          .collection('quizzes')
          .add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            'Quiz created successfully',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ManageQuestionsPage(
            quizId: docRef.id,
            quizTitle:
            titleController.text.trim(),
          ),
        ),
      );

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
          'Create Quiz',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: titleController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText: 'Quiz Title',

                labelStyle:
                const TextStyle(
                  color: Colors.white70,
                ),

                border:
                OutlineInputBorder(
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

              maxLines: 3,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText: 'Description',

                labelStyle:
                const TextStyle(
                  color: Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: isSaving ? null : saveQuiz,

                style: ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xFF9BD028,),

                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: isSaving ? const CircularProgressIndicator(
                  color: Colors.black,
                ) : const Text(
                  'CREATE QUIZ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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