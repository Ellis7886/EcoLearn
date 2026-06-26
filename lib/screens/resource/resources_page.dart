import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

import '../pdf_viewer_page.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/resource_card.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  Future<void> openFile(String url) async {

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

    } else {

      throw Exception(
        'Could not open file',
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(
        settings.darkTheme,
      ),

      appBar: AppBar(
        backgroundColor: AppColors.card(
          settings.darkTheme,
        ),

        title: Text(
          'Resources',
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No resources available',
                style: TextStyle(
                  color: AppColors.text(
                    settings.darkTheme,
                  ),
                ),
              ),
            );
          }

          final resources = snapshot.data!.docs
              .where((doc) => doc['type'] == 'material')
              .toList();

          Map<String, List<QueryDocumentSnapshot>> groupedResources = {};

          for (var resource in resources) {

            final chapter = resource['chapter'] ?? 'Additional Materials';

            if (!groupedResources.containsKey(chapter)) {
              groupedResources[chapter] = [];
            }

            groupedResources[chapter]!.add(resource);
          }

          return ListView(
            padding: const EdgeInsets.all(20),

            children: groupedResources.entries.map((entry) {

              final chapter = entry.key;
              final chapterResources = entry.value;

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration: BoxDecoration(
                  color: AppColors.card(settings.darkTheme,),
                  borderRadius: BorderRadius.circular(20,),
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
                          child: Text(
                            chapter,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            '${chapterResources.length}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    children: chapterResources.map((resource) {

                      IconData icon = Icons.description;

                      String fileName = resource['file_name'] ?? '';

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

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),

                        child: ResourceCard(
                          icon: icon,
                          title: resource['title'] ?? '',
                          description: resource['description'] ?? '',
                          chapter: resource['chapter'] ?? 'Additional Materials',
                          fileName: resource['file_name'] ?? '',

                          onOpen: () {

                            if (fileName
                                .toLowerCase()
                                .endsWith('.pdf')) {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerPage(
                                    pdfUrl: resource['file_url'],
                                    title: resource['title'],
                                  ),
                                ),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Only PDF preview is supported',),
                                ),
                              );
                            }
                          },
                        ),
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