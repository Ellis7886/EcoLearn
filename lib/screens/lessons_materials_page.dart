import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialsPage extends StatelessWidget {

  final String lessonId;
  final String lessonTitle;

  const MaterialsPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text(
          lessonTitle,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materials')
            .where(
          'lesson_id',
          isEqualTo: lessonId,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(!snapshot.hasData ||
              snapshot.data!.docs.isEmpty){

            return const Center(
              child: Text(
                'No materials available',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final materials =
              snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: materials.length,

            itemBuilder: (context, index) {

              final material =
              materials[index];

              return Container(
                margin:
                const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color:
                  const Color(0xFF2B2B2B),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: ListTile(

                  leading: const Icon(
                    Icons.description,
                    color: Color(0xFF9BD028),
                    size: 35,
                  ),

                  title: Text(
                    material['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    material['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),

                  onTap: () {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      SnackBar(
                        content: Text(
                          material['file_name'],
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