import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../themes/app_colors.dart';

import 'material_card.dart';

class ChapterCard extends StatefulWidget {
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
  State<ChapterCard> createState() => _ChapterCardState();
}

/// Normal Mode chapter card (live Firestore data).
class _ChapterCardState extends State<ChapterCard> {

  // CHANGED: the materials query is created once per card,
  // not on every rebuild.
  late final Stream<QuerySnapshot> _materialsStream =
  FirebaseFirestore.instance
      .collection('materials')
      .where('chapter_id', isEqualTo: widget.chapter.id)
      .snapshots();

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 15,),
      decoration: BoxDecoration(
        color: AppColors.card(widget.darkTheme,),
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.darkTheme ? [] : [
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
              color: AppColors.primaryLight(widget.darkTheme,),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
          ),

          iconColor: AppColors.text(widget.darkTheme,),
          collapsedIconColor: AppColors.text(widget.darkTheme,),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.chapter['title'] ?? '',
                  style: TextStyle(
                    color: AppColors.text(widget.darkTheme,),
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
                widget.chapter['description'] ?? '',
                style: TextStyle(
                  color: AppColors.subText(widget.darkTheme,),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            StreamBuilder<QuerySnapshot>(
              stream: _materialsStream,

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
                        color: AppColors.subText(widget.darkTheme),
                      ),
                    ),
                  );
                }

                final materials = materialSnapshot.data!.docs;

                return Column(
                  children: materials.map((material) {
                    return MaterialCard(
                      material: material,
                      darkTheme: widget.darkTheme,
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