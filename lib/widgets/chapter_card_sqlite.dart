import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

import '../controllers/material_controller.dart';
import 'material_card_sqlite.dart';

class ChapterCardSqlite extends StatefulWidget {

  final Map<String, dynamic> chapter;
  final bool darkTheme;
  final String lessonId;
  final int refreshCounter;

  const ChapterCardSqlite({
    super.key,
    required this.chapter,
    required this.darkTheme,
    required this.lessonId,
    required this.refreshCounter,
  });

  @override
  State<ChapterCardSqlite> createState() => _ChapterCardSQLiteState();
}

class _ChapterCardSQLiteState extends State<ChapterCardSqlite> {

  final MaterialController _materialController = MaterialController();

  List<Map<String, dynamic>> sqliteMaterials = [];

  bool isExpanded = false;

  Future<void> loadMaterials() async {

    final materials =
    await _materialController.getSQLiteMaterials(
        widget.chapter['id']);

    if (!mounted) return;

    setState(() {

      sqliteMaterials = materials;

    });
  }

  @override
  void didUpdateWidget(covariant ChapterCardSqlite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshCounter != widget.refreshCounter &&
        isExpanded) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          loadMaterials();
        }
      });

    }
  }

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
          onExpansionChanged: (expanded) async {
            isExpanded = expanded;

            if (isExpanded) {
              await loadMaterials();
            }
          },
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

            if (sqliteMaterials.isEmpty)

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No materials uploaded',
                  style: TextStyle(
                    color: AppColors.subText(widget.darkTheme),
                  ),
                ),
              )

            else

              Column(

                children: sqliteMaterials.map((material) {

                  return MaterialCardSqlite(

                    material: material,
                    darkTheme: widget.darkTheme,

                  );

                }).toList(),

              ),
          ],
        ),
      ),
    );
  }
}