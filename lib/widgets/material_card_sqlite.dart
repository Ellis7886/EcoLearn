import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';

import '../themes/app_colors.dart';

import '../helpers/material_handler.dart';

class MaterialCardSqlite extends StatelessWidget {

  final Map<String, dynamic> material;
  final bool darkTheme;

  const MaterialCardSqlite({
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
    }
    else if (fileType.contains('mp4') ||
        fileType.contains('video')) {
      icon = Icons.video_library;
    }
    else if (fileType.contains('jpg') ||
        fileType.contains('jpeg') ||
        fileType.contains('png') ||
        fileType.contains('image')) {
      icon = Icons.image;
    }
    else if (fileType.contains('doc') ||
        fileType.contains('docx') ||
        fileType.contains('word')) {
      icon = Icons.article;
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.card(darkTheme,),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border(darkTheme,),
        ),
        boxShadow: darkTheme
            ? []
            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(leading:
      Icon(
        icon,
        color: AppColors.primary,
      ),

          title: Text(
            material['title'],
            style: TextStyle(
              color: AppColors.text(darkTheme,),
            ),
          ),

        onTap: () async {

          final settings = Provider.of<AppSettings>(
            context,
            listen: false,
          );

          final fileType =
          (material['type'] ?? '')
              .toString()
              .toLowerCase();

          try {

            String materialUrl;

            // ========================================
            // NORMAL MODE
            // ========================================

            if (!settings.ecoMode) {

              debugPrint('========================');
              debugPrint('NORMAL MODE');
              debugPrint('Using ORIGINAL file');

              materialUrl =
              material['file_url'];

              debugPrint(
                'Original URL: $materialUrl',
              );

              debugPrint('========================');
            }

            // ========================================
            // ECO MODE
            // ========================================

            else {

              final ecoPath =
              material['eco_file_path'];

              if (ecoPath == null ||
                  ecoPath.toString().isEmpty) {

                throw Exception(
                  'Optimized file is not available yet.',
                );
              }

              debugPrint('========================');
              debugPrint('ECO MODE');
              debugPrint(
                'Using OPTIMIZED file',
              );

              debugPrint(
                'Optimized path: $ecoPath',
              );

              // Firebase Storage reference
              final storageRef =
              FirebaseStorage.instance
                  .ref()
                  .child(
                ecoPath.toString(),
              );

              // Get optimized file URL
              materialUrl =
              await storageRef.getDownloadURL();

              debugPrint(
                'Optimized URL: $materialUrl',
              );

              debugPrint('========================');
            }

            // ========================================
            // OPEN MATERIAL DIRECTLY
            // ========================================

            if (!context.mounted) return;

            MaterialHandler.openMaterial(
              context,
              fileType,
              materialUrl,
              material['title'],
              settings.ecoMode ? 'Eco' : 'Normal',
            );

          } catch (e) {

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to open material: $e',
                ),
              ),
            );

            debugPrint(
              'Material error: $e',
            );
          }
        },
      ),
    );
  }
}