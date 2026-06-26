import 'package:ecolearn/screens/lesson/create_content_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';

import '../../themes/app_colors.dart';

import '../../widgets/bottom_nav_bar.dart';

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
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
        backgroundColor: AppColors.background(
          settings.darkTheme,
        ),

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

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background(
          settings.darkTheme,
        ),

        title: Text(
          lessonTitle,
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content')
            .where('type', isEqualTo: 'chapter',)
            .where('lesson_id', isEqualTo: lessonId,)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(
              child: Text(
                'No chapters available',
                style: TextStyle(
                  color: AppColors.text(
                    settings.darkTheme,
                  ),
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
                margin: const EdgeInsets.only(bottom: 15,),

                decoration: BoxDecoration(
                  color: AppColors.card(
                    settings.darkTheme,
                  ),
                  borderRadius: BorderRadius.circular(20,),
                ),

                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),

                  child: ExpansionTile(

                    leading: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF9BD028),
                    ),

                    iconColor: AppColors.text(
                      settings.darkTheme,
                    ),
                    collapsedIconColor: AppColors.text(
                      settings.darkTheme,
                    ),

                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter['title'] ?? '',
                            style: TextStyle(
                              color: AppColors.text(
                                settings.darkTheme,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppColors.text(
                              settings.darkTheme,
                            ),
                          ),

                          onSelected: (value) async {

                            if (value == 'edit') {
                              // Navigate to Edit Chapter Page
                            }
                            else if (value == 'delete') {
                              final messenger = ScaffoldMessenger.of(context);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Chapter'),
                                  content: const Text(
                                    'Delete this chapter and all materials?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),

                                    TextButton(
                                      onPressed:() =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                // Delete all materials inside chapter
                                final materials = await FirebaseFirestore.instance
                                    .collection('content')
                                    .where('type', isEqualTo: 'material',)
                                    .where('chapter', isEqualTo: chapter['title'],
                                ).get();

                                for (var doc in materials.docs) {
                                  await doc.reference.delete();
                                }

                                // Delete chapter
                                await FirebaseFirestore.instance
                                    .collection('content')
                                    .doc(chapter.id)
                                    .delete();

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Chapter deleted successfully',
                                    ),
                                  ),
                                );
                              }
                            }
                          },

                          itemBuilder: (context) => const [

                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          style: TextStyle(
                            color: AppColors.subText(
                              settings.darkTheme,
                            ),
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

                          final materials = materialSnapshot.data!.docs;

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
                                  color: AppColors.card(
                                    settings.darkTheme,
                                  ),
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
                                      style: TextStyle(
                                        color: AppColors.text(
                                          settings.darkTheme,
                                        ),
                                      ),
                                    ),

                                    subtitle: Text(
                                      material['file_name'] ?? '',
                                      style: TextStyle(
                                        color: AppColors.subText(
                                          settings.darkTheme,
                                        ),
                                      ),
                                    ),

                                    trailing: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: AppColors.text(
                                          settings.darkTheme,
                                        ),
                                      ),

                                      onSelected: (value) async {

                                        if (value == 'edit') {
                                          // Navigate to EditMaterialPage
                                        }
                                        else if (value == 'delete') {
                                          final messenger = ScaffoldMessenger.of(context);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                'Delete Material',
                                              ),

                                              content: const Text(
                                                'Delete this material?',
                                              ),

                                              actions: [

                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),

                                                  child: const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),

                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.red,),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await FirebaseFirestore.instance
                                                .collection('content')
                                                .doc(material.id)
                                                .delete();

                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Material deleted',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },

                                      itemBuilder: (context) => const [

                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 10),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),

                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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