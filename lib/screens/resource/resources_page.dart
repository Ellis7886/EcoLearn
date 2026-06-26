import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../provider/app_settings.dart';
import '../../themes/app_colors.dart';

import '../pdf_viewer_page.dart';

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

          Map<String, Map<String, List<QueryDocumentSnapshot>>> groupedResources = {};

          for (var resource in resources) {

            final lesson = resource['lesson_title'] ?? 'Unknown Lesson';

            final chapter = resource['chapter'] ?? 'Additional Materials';

            groupedResources.putIfAbsent(
              lesson, () => {},
            );

            groupedResources[lesson]!.putIfAbsent(
              chapter, () => [],
            );

            groupedResources[lesson]![chapter]!.add(
              resource,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),

            children: groupedResources.entries.map((entry) {

              final chapter = entry.key;
              final chapterResources = entry.value;
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
                          child: Text(
                            chapter,
                            style: TextStyle(
                              color: settings.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                            '$totalMaterials Files',
                            style: TextStyle(
                              color: AppColors.subText(
                                settings.darkTheme,
                              ),
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
                            color: AppColors.text(
                              settings.darkTheme,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        children: resources.map((resource) {

                          return ListTile(
                            title: Text(
                              resource['title'],
                              style: TextStyle(
                                color: AppColors.text(
                                  settings.darkTheme,
                                ),
                              ),
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerPage(
                                    pdfUrl: resource['file_url'],
                                    title: resource['title'],
                                  ),
                                ),
                              );
                            },
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