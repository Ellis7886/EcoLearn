import 'package:flutter/material.dart';

import '../widgets/lesson_card.dart';
import '../services/firestore_service.dart';

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

                ElevatedButton(
                  onPressed: () async {
                    await FirestoreService.addTestData();
                  },

                  child: const Text('Test Firebase'),
                ),

                const SizedBox(height: 20),

                const LessonCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}