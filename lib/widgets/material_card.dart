import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../themes/app_colors.dart';
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
        // Normal Mode only (Eco Mode uses MaterialCardSqlite).
        // CHANGED: removed the unused Eco branch, which also
        // passed 'Normal' by mistake.
        onTap: () {
          final fileType = (material['type'] ?? '')
              .toString()
              .toLowerCase();

          MaterialHandler.openMaterial(
            context,
            fileType,
            material['file_url'],
            material['title'],
            'Normal',
          );
        },
      ),
    );
  }
}