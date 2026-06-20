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

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                'No resources available',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final resources = snapshot.data!.docs
              .where((doc) => doc['type'] == 'material')
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: resources.length,

            itemBuilder: (context, index) {

              final resource = resources[index];

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

              return ResourceCard(

                icon: icon,

                title:
                resource['title'] ?? '',

                description:
                resource['description'] ?? '',

                chapter:
                resource['chapter'] ??
                    'Additional Materials',

                fileName:
                resource['file_name'] ?? '',

                onOpen: () {

                  final String fileName =
                  resource['file_name'];

                  if (fileName
                      .toLowerCase()
                      .endsWith('.pdf')) {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            PdfViewerPage(
                              pdfUrl:
                              resource['file_url'],

                              title:
                              resource['title'],
                            ),
                      ),
                    );

                  } else {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content: Text(
                          'Only PDF preview is supported',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}