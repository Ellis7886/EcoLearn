import 'package:ecolearn/screens/add_questions_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageQuestionsPage extends StatelessWidget {

  final String quizId;
  final String quizTitle;

  const ManageQuestionsPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text(
          quizTitle,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9BD028),

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),

        onPressed: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => AddQuestionPage(
                quizId: quizId,
              ),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where(
          'quiz_id',
          isEqualTo: quizId,
        )
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

            return const Center(
              child: Text(
                'No questions added yet',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final questions =
              snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: questions.length,

            itemBuilder: (context, index) {

              final question =
              questions[index];

              return Container(
                margin:
                const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color:
                  const Color(0xFF2B2B2B),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: ListTile(

                  leading: CircleAvatar(
                    backgroundColor:
                    const Color(
                      0xFF9BD028,
                    ),

                    child: Text(
                      '${index + 1}',
                      style:
                      const TextStyle(
                        color:
                        Colors.black,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    question['question'],
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Correct Answer: ${question['correct_answer']}',
                    style:
                    const TextStyle(
                      color:
                      Colors.white70,
                    ),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color:
                    Colors.white54,
                    size: 16,
                  ),

                  onTap: () {

                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(

                      SnackBar(
                        content: Text(
                          question['question'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}