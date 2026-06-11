import 'package:ecolearn/screens/create_content_page.dart';
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9BD028),

        onPressed: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => CreateContentPage(
                lessonId: lessonId,
                lessonTitle: lessonTitle,
              ),
            ),
          );
        },

        child: const Icon(
          Icons.upload_file,
          color: Colors.black,
        ),
      ),

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
            .collection('content')
            .where('type', isEqualTo: 'chapter',)
            .where('lesson_id', isEqualTo: lessonId,)
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
                'No chapters available',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final chapters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: chapters.length,

            itemBuilder: (context, index) {

              final chapter = chapters[index];

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration:
                BoxDecoration(
                  color: const Color(0xFF2B2B2B,),

                  borderRadius:
                  BorderRadius.circular(20,),
                ),

                child: Theme(
                  data: Theme.of(context)
                      .copyWith(
                    dividerColor: Colors.transparent,
                  ),

                  child: ExpansionTile(

                    leading:
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF9BD028),
                    ),

                    iconColor: Colors.white,

                    collapsedIconColor: Colors.white,

                    title: Text(
                      chapter['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    childrenPadding:
                    const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),

                    children: [

                      Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          chapter['description'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('content')
                            .where('type', isEqualTo: 'material',)
                            .where('chapter', isEqualTo: chapter['title'],)
                            .snapshots(),

                        builder: (context, materialSnapshot) {
                          if (!materialSnapshot
                              .hasData ||
                              materialSnapshot
                                  .data!
                                  .docs
                                  .isEmpty) {

                            return const Align(
                              alignment: Alignment.centerLeft,

                              child: Text(
                                'No materials uploaded',
                                style:
                                TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          }

                          final materials =
                              materialSnapshot
                                  .data!
                                  .docs;

                          return Column(
                            children: materials.map((material) {

                                IconData icon = Icons.description;

                                String fileName = material['file_name'] ?? '';

                                if (fileName.toLowerCase().endsWith('.pdf')) {
                                  icon = Icons.picture_as_pdf;
                                }
                                else if (fileName.toLowerCase().endsWith('.mp4')) {
                                  icon = Icons.video_library;
                                }
                                else if (fileName.toLowerCase().endsWith('.jpg') ||
                                    fileName.toLowerCase().endsWith('.jpeg') ||
                                    fileName.toLowerCase().endsWith('.png')) {
                                  icon = Icons.image;
                                }

                                return Card(
                                  color: Colors.black26,

                                  margin:
                                  const EdgeInsets.only(
                                    bottom: 10,
                                  ),

                                  child:
                                  ListTile(leading:
                                    Icon(
                                      icon,
                                      color: const Color(0xFF9BD028),
                                    ),

                                    title:
                                    Text(
                                      material['title'],
                                      style:
                                      const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),

                                    subtitle: Text(
                                      material['file_name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    trailing:
                                    const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      color: Colors.white54,
                                      size:
                                      16,
                                    ),

                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                          Text(material['title'],),
                                        ),
                                      );

                                      // Future:
                                      // Open PDF
                                      // Open Video
                                      // Open Image
                                    },
                                  ),
                                );
                              },
                            ).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}