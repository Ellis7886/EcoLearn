import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

import '../pdf_viewer_page.dart';
import '../video_player_page.dart';
import '../image_viewer_page.dart';

import '../../widgets/bottom_nav_bar.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  Future<void> openFile(String url) async {

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    else {
      throw Exception(
        'Could not open file',
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(settings.darkTheme,),

      appBar: AppBar(
        backgroundColor: AppColors.card(settings.darkTheme,),

        title: Text(
          'Resources',
          style: TextStyle(
            color: AppColors.text(settings.darkTheme,),
          ),
        ),

        iconTheme: IconThemeData(
          color: AppColors.text(settings.darkTheme,),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index){},
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content')
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No resources available',
                style: TextStyle(
                  color: AppColors.text(settings.darkTheme,),
                ),
              ),
            );
          }

          final resources = snapshot.data!.docs
              .where((doc) => doc['type'] == 'material')
              .toList();

          if (resources.isEmpty) {
            return Center(
              child: Text(
                'No resources available',
                style: TextStyle(
                  color: AppColors.text(settings.darkTheme),
                ),
              ),
            );
          }

          Map<String, dynamic> groupedResources = {};

          for (var resource in resources) {
            final data = resource.data() as Map<String, dynamic>;
            final lesson = resource['lesson_title'] ?? 'Unknown Lesson';
            final courseCode = data['course_code'] ?? '';
            final chapter = resource['chapter'] ?? 'Additional Materials';

            groupedResources.putIfAbsent(
              lesson,
                  () => {
                'courseCode': courseCode,
                'chapters': <String, List<QueryDocumentSnapshot>>{},
              },
            );

            (groupedResources[lesson]['chapters']
            as Map<String, List<QueryDocumentSnapshot>>).putIfAbsent(
              chapter, () => <QueryDocumentSnapshot>[],
            );

            groupedResources[lesson]['chapters'][chapter].add(resource);
          }

          return ListView(
            padding: const EdgeInsets.all(20),

            children: groupedResources.entries.map((entry) {

              final lessonTitle = entry.key;
              final courseCode = entry.value['courseCode'];
              final chapterResources = entry.value['chapters'] as Map<String, List<QueryDocumentSnapshot>>;
              final totalMaterials = chapterResources.values.fold<int>(0, (total, list) => total + list.length,);

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color: settings.darkTheme
                      ? const Color(0xFF2B2B2B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: settings.darkTheme ? [] : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),

                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    childrenPadding: const EdgeInsets.all(15,),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.primary,

                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lessonTitle,
                                style: TextStyle(
                                  color: settings.darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                courseCode,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20,),
                          ),

                          child: Text(
                            '$totalMaterials Files',
                            style: TextStyle(
                              color: AppColors.subText(settings.darkTheme,),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    children: chapterResources.entries.map((chapterEntry) {
                      final chapterName = chapterEntry.key;
                      final resources = chapterEntry.value;
                      return ExpansionTile(
                        title: Text(
                          chapterName,
                          style: TextStyle(
                            color: AppColors.text(settings.darkTheme,),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        children: resources.map((resource) {

                          IconData icon = Icons.description;

                          final fileType = (resource['file_type'] ?? '')
                              .toString()
                              .toLowerCase();

                          String subtitle = 'Open Material';

                          if (fileType.contains('pdf')) {
                            icon = Icons.picture_as_pdf;
                            subtitle = 'Open PDF';
                          }
                          else if (fileType.contains('video') ||
                              fileType.contains('mp4')) {
                            icon = Icons.video_library;
                            subtitle = 'Watch Video';
                          }
                          else if (fileType.contains('jpg') ||
                              fileType.contains('jpeg') ||
                              fileType.contains('png') ||
                              fileType.contains('image')) {
                            icon = Icons.image;
                            subtitle = 'View Image';
                          }
                          else if (fileType.contains('doc') ||
                              fileType.contains('docx')) {
                            icon = Icons.article;
                            subtitle = 'Open Document';
                          }

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),

                            decoration: BoxDecoration(
                              color: settings.darkTheme
                                  ? const Color(0xFF1F1F1F)
                                  : const Color(0xFFF5F9EF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),

                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10,),
                                ),

                                child: Icon(
                                  icon,
                                  color: AppColors.primary,
                                ),
                              ),

                              title: Text(
                                resource['title'],
                                style: TextStyle(
                                  color: AppColors.text(settings.darkTheme,),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              subtitle: Text(
                                subtitle,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),

                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),

                              onTap: () {
                                final fileType = (resource['file_type'] ?? '')
                                    .toString()
                                    .toLowerCase();

                                if (fileType.contains('pdf')) {Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PdfViewerPage(
                                        pdfUrl: resource['file_url'],
                                        title: resource['title'],
                                      ),
                                    ),
                                  );
                                }
                                else if (fileType.contains('video') ||
                                    fileType.contains('mp4')) {Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerPage(
                                        videoUrl: resource['file_url'],
                                        title: resource['title'],
                                      ),
                                    ),
                                  );
                                }
                                else if (fileType.contains('jpg') ||
                                    fileType.contains('jpeg') ||
                                    fileType.contains('png') ||
                                    fileType.contains('image')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImageViewerPage(
                                        imageUrl: resource['file_url'],
                                        title: resource['title'],
                                      ),
                                    ),
                                  );
                                }
                                else {
                                  openFile(resource['file_url']);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}