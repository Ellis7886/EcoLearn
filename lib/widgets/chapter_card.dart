import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../themes/app_colors.dart';

import 'material_card.dart';

class ChapterCard extends StatelessWidget {

  final QueryDocumentSnapshot chapter;
  final bool darkTheme;
  final String lessonId;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.darkTheme,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 15,),
      decoration: BoxDecoration(
        color: AppColors.card(darkTheme,),
        borderRadius: BorderRadius.circular(20),
        boxShadow: darkTheme ? [] : [
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
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primaryLight(darkTheme,),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
          ),

          iconColor: AppColors.text(darkTheme,),
          collapsedIconColor: AppColors.text(darkTheme,),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  chapter['title'] ?? '',
                  style: TextStyle(
                    color: AppColors.text(darkTheme,),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          childrenPadding:
          const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),

          children: [

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                chapter['description'] ?? '',
                style: TextStyle(
                  color: AppColors.subText(darkTheme,),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('materials')
                  .where('chapter_id', isEqualTo: chapter.id)
                  .snapshots(),

              builder: (context, materialSnapshot) {
                if (!materialSnapshot
                    .hasData ||
                    materialSnapshot
                        .data!
                        .docs
                        .isEmpty) {

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No materials uploaded',
                      style: TextStyle(
                        color: AppColors.subText(darkTheme),
                      ),
                    ),
                  );
                }

                final materials = materialSnapshot.data!.docs;

                return Column(
                  children: materials.map((material) {
                    return MaterialCard(
                      material: material,
                      darkTheme: darkTheme,
                    );
                  },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}