import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';

import '../services/material_service.dart';
import '../services/file_service.dart';

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

            final materialService = MaterialService();
            final fileService = FileService();

            final localMaterial =
            await materialService.getMaterialById(
              material.id,
            );

            final fileType =
            (material['type'] ?? '')
                .toString()
                .toLowerCase();

            // ========================================
            // Determine current mode
            // ========================================

            final String currentMode =
            settings.ecoMode ? 'eco' : 'normal';

            // ========================================
            // Get local information
            // ========================================

            String? localPath =
            localMaterial?['local_path'];

            String? localMode =
            localMaterial?['local_mode'];

            // ========================================
            // Check whether correct version
            // is already downloaded
            // ========================================

            if (localPath != null &&
                localPath.isNotEmpty &&
                File(localPath).existsSync() &&
                localMode == currentMode) {

              debugPrint('OPEN LOCAL FILE');
              debugPrint('Mode: $currentMode');
              debugPrint('Path: $localPath');

              MaterialHandler.openMaterial(
                context,
                fileType,
                localPath,
                material['title'],
              );

              return;
            }

            // ========================================
            // Show downloading message
            // ========================================

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  settings.ecoMode
                      ? 'Downloading Eco Mode version...'
                      : 'Downloading Normal Mode version...',
                ),
              ),
            );

            try {

              // ========================================
              // Select file
              // ========================================

              String downloadUrl =
              material['file_url'];

              String downloadFileName =
              material['file_name'];

              // ========================================
              // ECO MODE
              // ========================================

              if (settings.ecoMode) {

                final ecoPath =
                material['eco_file_path'];

                if (ecoPath == null ||
                    ecoPath.toString().isEmpty) {

                  throw Exception(
                    'Optimized file is not available yet.',
                  );
                }

                debugPrint('ECO MODE');
                debugPrint(
                  'Optimized path: $ecoPath',
                );

                final storageRef =
                FirebaseStorage.instance
                    .ref()
                    .child(
                  ecoPath.toString(),
                );

                downloadUrl =
                await storageRef.getDownloadURL();

                downloadFileName =
                    ecoPath
                        .toString()
                        .split('/')
                        .last;
              }

              // ========================================
              // NORMAL MODE
              // ========================================

              else {

                debugPrint('NORMAL MODE');

                debugPrint(
                  'Original URL: ${material['file_url']}',
                );
              }

              // ========================================
              // Download selected version
              // ========================================

              final filePath =
              await fileService.downloadFile(
                downloadUrl,
                downloadFileName,
              );

              debugPrint(
                'Downloaded path = $filePath',
              );

              // ========================================
              // Save local path + mode
              // ========================================

              await materialService.updateLocalMaterial(
                material.id,
                filePath,
                currentMode,
              );

              // ========================================
              // Download completed
              // ========================================

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Download completed',
                  ),
                ),
              );

              // ========================================
              // Open file
              // ========================================

              MaterialHandler.openMaterial(
                context,
                fileType,
                filePath,
                material['title'],
              );

            } catch (e) {

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Download failed: $e',
                  ),
                ),
              );

              debugPrint(
                'Material download error: $e',
              );
            }
          }
      ),
    );
  }
}