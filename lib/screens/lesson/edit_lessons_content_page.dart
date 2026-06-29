import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLessonsContentPage extends StatefulWidget {

  final String documentId;
  final Map<String, dynamic> material;

  const EditLessonsContentPage({
    super.key,
    required this.documentId,
    required this.material,
  });

  @override
  State<EditLessonsContentPage> createState() =>
      _EditLessonsContentPageState();
}

class _EditLessonsContentPageState
    extends State<EditLessonsContentPage> {

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.material['title'] ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.material['description'] ?? '',
    );
  }

  Future<void> updateMaterial() async {

    await FirebaseFirestore.instance
        .collection('content')
        .doc(widget.documentId)
        .update({

      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),

    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content updated successfully'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Content',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: updateMaterial,

                child: const Text(
                  'Save Changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}