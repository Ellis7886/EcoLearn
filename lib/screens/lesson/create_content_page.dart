import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CreateContentPage extends StatefulWidget {

  final String lessonId;
  final String lessonTitle;
  final String lessonCode;

  const CreateContentPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonCode,
  });

  @override
  State<CreateContentPage> createState() =>
      _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedLesson;
  String? selectedChapter = "Additional";
  String contentType = 'chapter';
  List<File> selectedFiles = [];
  List<String> fileNames = [];
  bool isUploading = false;

  Future<void> pickFile() async {

    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {

      setState(() {

        selectedFiles = result.paths
            .map((path) => File(path!))
            .toList();

        fileNames = result.files
            .map((file) => file.name)
            .toList();
      });
    }
  }

  Future<void> postContent() async {
    if (titleController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
        ),
      );
      return;
    }

    if (contentType == 'material' && selectedFiles.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isUploading = true;
      });

      if (contentType == 'material') {

        for (int i = 0;
        i < selectedFiles.length;
        i++) {

          final storageRef = FirebaseStorage.instance
              .ref()
              .child(
            'content/${fileNames[i]}',
          );

          await storageRef.putFile(
            selectedFiles[i],
          );

          final fileUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('content')
              .add({

            'lesson_id': widget.lessonId,
            'lesson_title': widget.lessonTitle,
            'course_code': widget.lessonCode,
            'type': 'material',
            'chapter': selectedChapter,
            'title': fileNames[i],
            'description': descriptionController.text.trim(),
            'file_name': fileNames[i],
            'file_url': fileUrl,
            'created_at': Timestamp.now(),
          });
        }
      }
      else {

        await FirebaseFirestore.instance
            .collection('content')
            .add({

          'lesson_id': widget.lessonId,
          'lesson_title': widget.lessonTitle,
          'course_code': widget.lessonCode,
          'type': 'chapter',
          'chapter': '',
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'file_name': '',
          'file_url': '',
          'created_at': Timestamp.now(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posted successfully'),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {isUploading = false;});
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
          'Create Content',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Text(
                'Lesson: ${widget.lessonTitle}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Content Type',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(

              initialValue: contentType,

              dropdownColor: Colors.grey[900],

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      15
                  ),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'chapter',
                  child: Text('Chapter'),
                ),

                DropdownMenuItem(
                  value: 'material',
                  child: Text('Material'),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  contentType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Title',
                border:
                    OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,

              maxLines: 5,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText: 'Description',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            if (contentType == 'material')
              Column(children: [

                  const SizedBox(height: 20),

                  if (widget.lessonId.isNotEmpty)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('content')
                          .where('type', isEqualTo: 'chapter',)
                          .where('lesson_id', isEqualTo: widget.lessonId,)
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final chapters = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(

                          initialValue: selectedChapter,

                          dropdownColor: Colors.grey[900],

                          style: const TextStyle(
                            color: Colors.white,
                          ),

                          decoration: InputDecoration(
                            labelText: 'Select Chapter',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),

                          items: [

                            const DropdownMenuItem(
                              value: 'Additional',
                              child: Text(
                                'Additional Materials',
                              ),
                            ),

                            ...chapters.map(
                                  (chapter) {

                                return DropdownMenuItem<String>(
                                  value: chapter['title'],

                                  child: Text(
                                    chapter['title'],
                                  ),
                                );
                              },
                            ),
                          ],

                          onChanged: (value) {

                            setState(() {
                              selectedChapter = value;
                            });
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(

                      onPressed: pickFile,

                      icon: const Icon(
                        Icons.attach_file,
                      ),

                      label: const Text(
                        'Select File',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children:

                  fileNames.isEmpty

                      ? [
                    const Text(
                      'No file selected',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ]

                      : fileNames.map((name) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 5,
                      ),

                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                )
                ],
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: isUploading ? null : postContent,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9BD028),

                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: isUploading ? const CircularProgressIndicator(
                  color: Colors.black,
                ) : const Text(
                  'POST',
                  style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold)
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}