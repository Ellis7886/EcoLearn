import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';
import '../helpers/material_handler.dart';
import '../provider/app_settings.dart';

class MaterialCard extends StatelessWidget {
  final QueryDocumentSnapshot material;
  final bool darkTheme;

  const MaterialCard({
    super.key,
    required this.material,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.description;

    final fileType = (material['type'] ?? '')
        .toString()
        .toLowerCase();

    if (fileType.contains('pdf')) {
      icon = Icons.picture_as_pdf;
    } else if (fileType.contains('mp4') ||
        fileType.contains('video')) {
      icon = Icons.video_library;
    } else if (fileType.contains('jpg') ||
        fileType.contains('jpeg') ||
        fileType.contains('png') ||
        fileType.contains('image')) {
      icon = Icons.image;
    } else if (fileType.contains('doc') ||
        fileType.contains('docx') ||
        fileType.contains('word')) {
      icon = Icons.article;
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(darkTheme),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border(darkTheme),
        ),
        boxShadow: darkTheme
            ? []
            : [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          material['title'],
          style: TextStyle(
            color: AppColors.text(darkTheme),
          ),
        ),
        onTap: () async {
          final settings = Provider.of<AppSettings>(
            context,
            listen: false,
          );

          final fileType = (material['type'] ?? '')
              .toString()
              .toLowerCase();

          // ========================================
          // NORMAL MODE
          // ========================================

          if (!settings.ecoMode) {
            debugPrint('============================');
            debugPrint('NORMAL MODE');
            debugPrint('Using ORIGINAL file');
            debugPrint(
              'Original URL: ${material['file_url']}',
            );
            debugPrint('============================');

            MaterialHandler.openMaterial(
              context,
              fileType,
              material['file_url'],
              material['title'],
              'Normal',
            );

            return;
          }

          // ========================================
          // ECO MODE
          // ========================================

          try {
            final ecoPath = material['eco_file_path'];

            if (ecoPath == null ||
                ecoPath.toString().isEmpty) {
              throw Exception(
                'Optimized file is not available yet.',
              );
            }

            debugPrint('============================');
            debugPrint('ECO MODE');
            debugPrint('Using OPTIMIZED file');
            debugPrint(
              'Optimized path: $ecoPath',
            );
            debugPrint('============================');

            // Get Firebase Storage reference
            final storageRef = FirebaseStorage.instance
                .ref()
                .child(
              ecoPath.toString(),
            );

            // Get optimized file URL
            final optimizedUrl =
            await storageRef.getDownloadURL();

            debugPrint(
              'Optimized URL: $optimizedUrl',
            );

            // ========================================
            // Open optimized file directly
            // No download
            // No local storage
            // ========================================

            MaterialHandler.openMaterial(
              context,
              fileType,
              optimizedUrl,
              material['title'],
              'Normal',
            );
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Eco Mode failed: $e',
                ),
              ),
            );

            debugPrint(
              'Eco Mode error: $e',
            );
          }
        },
      ),
    );
  }
}