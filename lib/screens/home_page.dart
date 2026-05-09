import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/lesson_card.dart';
import'../models/lesson.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Center(
                  child: Image.asset(
                    'assets/images/ecolearn_logo.png',
                    height: 300,
                  ),
                ),

                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('lessons')
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {

                      return const Text(
                        'No lessons found',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    final lessons = snapshot.data!.docs;

                    return Column(
                      children: lessons.map((doc) {
                        final lesson = Lesson.fromFirestore(doc.data());
                        return LessonCard(
                          title: lesson.title,
                          description: lesson.description,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}