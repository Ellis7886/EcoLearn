import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

class CreateQuizPage extends StatefulWidget {
  final String lessonId;

  const CreateQuizPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<CreateQuizPage> createState() =>
      _CreateQuizPageState();
}

class _CreateQuizPageState
    extends State<CreateQuizPage> {

  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  bool isSaving = false;

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();

    addQuestion();
  }

  void addQuestion() {

    setState(() {

      questions.add({
        'questionController': TextEditingController(),
        'optionAController': TextEditingController(),
        'optionBController': TextEditingController(),
        'optionCController': TextEditingController(),
        'optionDController': TextEditingController(),
        'correctAnswer': 'A',
      });
    });
  }

  Future<void> createQuiz() async {

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter quiz title',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      List<Map<String, dynamic>>
      quizQuestions = [];

      for (var question in questions) {

        quizQuestions.add({
          'question': question['questionController']
              .text
              .trim(),

          'option_a': question['optionAController']
              .text
              .trim(),

          'option_b': question['optionBController']
              .text
              .trim(),

          'option_c': question['optionCController']
              .text
              .trim(),

          'option_d': question['optionDController']
              .text
              .trim(),

          'correct_answer': question['correctAnswer'],
        });
      }

      await FirebaseFirestore.instance
          .collection('quizzes')
          .add({

        'lesson_id':
        widget.lessonId,

        'title':
        titleController.text.trim(),

        'description':
        descriptionController.text.trim(),

        'questions':
        quizQuestions,

        'created_at':
        Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz created successfully',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final settings =
    Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor:
      AppColors.background(
        settings.darkTheme,
      ),

      appBar: AppBar(
        backgroundColor:
        AppColors.background(
          settings.darkTheme,
        ),

        title: Text(
          'Create Quiz',
          style: TextStyle(
            color: AppColors.text(
              settings.darkTheme,
            ),
          ),
        ),

        iconTheme: IconThemeData(
          color: AppColors.text(
            settings.darkTheme,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              padding:
              const EdgeInsets.all(
                20,
              ),

              decoration:
              BoxDecoration(
                color:
                AppColors.card(
                  settings.darkTheme,
                ),

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(
                children: [

                  TextField(
                    controller:
                    titleController,

                    decoration:
                    const InputDecoration(
                      labelText:
                      'Quiz Title',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller:
                    descriptionController,

                    maxLines: 3,

                    decoration:
                    const InputDecoration(
                      labelText:
                      'Description',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ...questions
                .asMap()
                .entries
                .map((entry) {

              int index = entry.key;

              var question = entry.value;

              return Container(
                margin:
                const EdgeInsets.only(
                  bottom: 20,
                ),

                padding:
                const EdgeInsets.all(
                  20,
                ),

                decoration:
                BoxDecoration(
                  color:
                  AppColors.card(
                    settings.darkTheme,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed: () {

                            setState(() {

                              questions.removeAt(index);

                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    TextField(
                      controller:
                      question[
                      'questionController'],
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Question',
                      ),
                    ),

                    TextField(
                      controller:
                      question[
                      'optionAController'],
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Option A',
                      ),
                    ),

                    TextField(
                      controller:
                      question[
                      'optionBController'],
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Option B',
                      ),
                    ),

                    TextField(
                      controller:
                      question[
                      'optionCController'],
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Option C',
                      ),
                    ),

                    TextField(
                      controller:
                      question[
                      'optionDController'],
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Option D',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                      question[
                      'correctAnswer'],

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Correct Answer',
                      ),

                      items:
                      ['A','B','C','D']
                          .map(
                            (e) =>
                            DropdownMenuItem(
                              value:
                              e,
                              child:
                              Text(
                                e,
                              ),
                            ),
                      )
                          .toList(),

                      onChanged:
                          (value) {

                        setState(() {

                          question[
                          'correctAnswer'] =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton.icon(
                onPressed:
                addQuestion,

                icon: const Icon(
                  Icons.add,
                ),

                label: const Text(
                  'Add Question',
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed:
                isSaving
                    ? null
                    : createQuiz,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  AppColors.primary,
                ),

                child:
                isSaving
                    ? const CircularProgressIndicator(
                  color:
                  Colors.black,
                )
                    : const Text(
                  'CREATE QUIZ',
                  style:
                  TextStyle(
                    color:
                    Colors.black,
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