import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../themes/app_colors.dart';

import '../services/material_service.dart';
import '../services/file_service.dart';

import '../helpers/material_handler.dart';

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

            final materialService = MaterialService();
            final fileService = FileService();

            final localMaterial = await materialService.getMaterialById(
              material.id,
            );

            final fileType = (material['type'] ?? '').toString().toLowerCase();

            String? localPath = localMaterial?['local_path'];

            // Already downloaded
            if (localPath != null &&
                localPath.isNotEmpty &&
                File(localPath).existsSync()) {

              print('OPEN LOCAL FILE');

              MaterialHandler.openMaterial(
                context,
                fileType,
                localPath,
                material['title'],
              );

              return;
            }

            // Show downloading message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Downloading ${material['title']}...',
                ),
              ),
            );

            try {

              final filePath = await fileService.downloadFile(
                material['file_url'],
                material['file_name'],
              );

              debugPrint("Downloaded path = $filePath");

              await materialService.updateLocalPath(
                material.id,
                filePath,
              );


              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Download completed',
                  ),
                ),
              );

              MaterialHandler.openMaterial(
                context,
                fileType,
                filePath,
                material['title'],
              );

            } catch (e) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Download failed: $e',
                  ),
                ),
              );
            }
          }
      ),
    );
  }
}