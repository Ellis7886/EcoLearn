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

        iconTheme: const IconThemeData(
          color: Colors.white,
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

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                decoration:
                BoxDecoration(
                  color: const Color(0xFF2B2B2B,),

                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),

                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),

                  child: ExpansionTile(

                    leading: Icon(
                      icon,
                      color: const Color(0xFF9BD028),
                      size: 35,
                    ),

                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,

                    title: Text(
                      resource['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    childrenPadding:
                    const EdgeInsets.all(16),

                    children: [

                      Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          resource['description'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          'Chapter: ${resource['chapter'] ?? 'Additional Materials'}',

                          style: const TextStyle(
                            color: Color(0xFF9BD028),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          resource['file_name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(

                          onPressed: () {

                            final String fileName =
                            resource['file_name'];

                            if(fileName
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

                          icon: const Icon(
                            Icons.open_in_new,
                          ),

                          label: const Text(
                            'Open Material',
                          ),

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF9BD028,
                            ),

                            foregroundColor: Colors.white,
                          ),
                        ),
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