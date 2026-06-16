import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionPage extends StatefulWidget {

  final String quizId;

  const AddQuestionPage({
    super.key,
    required this.quizId,
  });

  @override
  State<AddQuestionPage> createState() =>
      _AddQuestionPageState();
}

class _AddQuestionPageState
    extends State<AddQuestionPage> {

  final questionController =
  TextEditingController();

  final optionAController =
  TextEditingController();

  final optionBController =
  TextEditingController();

  final optionCController =
  TextEditingController();

  final optionDController =
  TextEditingController();

  String correctAnswer = 'A';

  String mediaType = 'none';

  File? selectedFile;

  String fileName = '';

  bool isSaving = false;

  Future<void> pickFile() async {

    FilePickerResult? result =
    await FilePicker.pickFiles();

    if (result != null) {

      setState(() {

        selectedFile =
            File(result.files.single.path!);

        fileName =
            result.files.single.name;
      });
    }
  }

  Future<void> saveQuestion() async {

    if (questionController.text.trim().isEmpty ||
        optionAController.text.trim().isEmpty ||
        optionBController.text.trim().isEmpty ||
        optionCController.text.trim().isEmpty ||
        optionDController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text('Please complete all fields'),
        ),
      );

      return;
    }

    try {

      setState(() {
        isSaving = true;
      });

      String mediaUrl = '';

      if (selectedFile != null) {

        final storageRef =
        FirebaseStorage.instance
            .ref()
            .child(
          'question_media/$fileName',
        );

        await storageRef.putFile(
          selectedFile!,
        );

        mediaUrl =
        await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('questions')
          .add({

        'quiz_id':
        widget.quizId,

        'question':
        questionController.text.trim(),

        'optionA':
        optionAController.text.trim(),

        'optionB':
        optionBController.text.trim(),

        'optionC':
        optionCController.text.trim(),

        'optionD':
        optionDController.text.trim(),

        'correct_answer':
        correctAnswer,

        'media_type':
        mediaType,

        'media_url':
        mediaUrl,

        'created_at':
        Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text('Question added'),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text('Error: $e'),
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
          'Add Question',
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
              controller:
              questionController,

              maxLines: 3,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              InputDecoration(
                labelText:
                'Question',

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              optionAController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Option A',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              optionBController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Option B',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              optionCController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Option C',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              optionDController,

              style:
              const TextStyle(
                color: Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Option D',
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

              initialValue:
              correctAnswer,

              dropdownColor:
              Colors.grey[900],

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Correct Answer',
              ),

              items: const [

                DropdownMenuItem(
                  value: 'A',
                  child: Text('A'),
                ),

                DropdownMenuItem(
                  value: 'B',
                  child: Text('B'),
                ),

                DropdownMenuItem(
                  value: 'C',
                  child: Text('C'),
                ),

                DropdownMenuItem(
                  value: 'D',
                  child: Text('D'),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  correctAnswer =
                  value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

              initialValue:
              mediaType,

              dropdownColor:
              Colors.grey[900],

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Media Type',
              ),

              items: const [

                DropdownMenuItem(
                  value: 'none',
                  child: Text('None'),
                ),

                DropdownMenuItem(
                  value: 'image',
                  child: Text('Image'),
                ),

                DropdownMenuItem(
                  value: 'video',
                  child: Text('Video'),
                ),

                DropdownMenuItem(
                  value: 'audio',
                  child: Text('Audio'),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  mediaType =
                  value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(

              onPressed: pickFile,

              icon:
              const Icon(
                Icons.attach_file,
              ),

              label:
              const Text(
                'Upload Media',
              ),
            ),

            const SizedBox(height: 10),

            Text(
              fileName.isEmpty
                  ? 'No media selected'
                  : fileName,

              style:
              const TextStyle(
                color:
                Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed:
                isSaving
                    ? null
                    : saveQuestion,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF9BD028,
                  ),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child:
                isSaving

                    ? const CircularProgressIndicator(
                  color:
                  Colors.black,
                )

                    : const Text(
                  'SAVE QUESTION',
                  style:
                  TextStyle(
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