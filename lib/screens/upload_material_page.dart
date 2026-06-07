import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class UploadMaterialPage extends StatefulWidget {
  const UploadMaterialPage({super.key});

  @override
  State<UploadMaterialPage> createState() =>
      _UploadMaterialPageState();
}

class _UploadMaterialPageState
    extends State<UploadMaterialPage> {

  final titleController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  String? selectedLesson;

  File? selectedFile;

  String fileName = '';

  bool isUploading = false;

  Future<void> pickFile() async {

    FilePickerResult? result =
    await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'ppt',
        'pptx',
        'doc',
        'docx',
      ],
    );

    if(result != null){

      setState(() {

        selectedFile =
            File(result.files.single.path!);

        fileName =
            result.files.single.name;
      });
    }
  }

  Future<void> uploadMaterial() async {

    if(titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedLesson == null ||
        selectedFile == null){

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
        isUploading = true;
      });

      final storageRef =
      FirebaseStorage.instance
          .ref()
          .child(
          'materials/$fileName');

      await storageRef.putFile(
        selectedFile!,
      );

      final downloadUrl =
      await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('materials')
          .add({

        'title':
        titleController.text.trim(),

        'description':
        descriptionController.text.trim(),

        'lesson_id':
        selectedLesson,

        'file_name':
        fileName,

        'file_url':
        downloadUrl,

        'uploaded_at':
        Timestamp.now(),
      });

      if(!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text('Material uploaded successfully'),
        ),
      );

      Navigator.pop(context);

    } catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text('Upload failed: $e'),
        ),
      );

    } finally {

      if(mounted){

        setState(() {
          isUploading = false;
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
          'Upload Material',
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
          children: [

            TextField(
              controller: titleController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText:
                'Material Title',

                labelStyle:
                const TextStyle(
                  color: Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
              descriptionController,

              maxLines: 3,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                labelText:
                'Description',

                labelStyle:
                const TextStyle(
                  color: Colors.white70,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance
                  .collection('lessons')
                  .snapshots(),

              builder:
                  (context, snapshot) {

                if(!snapshot.hasData){

                  return const CircularProgressIndicator();
                }

                final lessons =
                    snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  initialValue: selectedLesson,

                  dropdownColor:
                  Colors.grey[900],

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    labelText:
                    'Select Lesson',

                    labelStyle:
                    const TextStyle(
                      color:
                      Colors.white70,
                    ),

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),

                  items:
                  lessons.map((doc) {

                    return DropdownMenuItem(
                      value: doc.id,

                      child: Text(
                        doc['title'],
                      ),
                    );

                  }).toList(),

                  onChanged: (value){

                    setState(() {
                      selectedLesson =
                          value;
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

            Text(
              fileName.isEmpty
                  ? 'No file selected'
                  : fileName,

              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                isUploading
                    ? null
                    : uploadMaterial,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF9BD028),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child:
                isUploading

                    ? const CircularProgressIndicator(
                  color: Colors.black,
                )

                    : const Text(
                  'Upload Material',
                  style: TextStyle(
                    color: Colors.black,
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