import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';

class LessonCard extends StatelessWidget {

  final String title;
  final String description;
  final String courseCode;
  final double progress;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(
          bottom: 20,
        ),

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: AppColors.card(
            settings.darkTheme,
          ),

          borderRadius: BorderRadius.circular(20),

          boxShadow:
          settings.darkTheme ? [] : [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4,),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: AppColors.primaryLight(settings.darkTheme,),

                    borderRadius:
                    BorderRadius.circular(12,),
                  ),

                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Tooltip(
                        message: title,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text(settings.darkTheme),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        courseCode,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              description,

              style: TextStyle(
                color:
                AppColors.subText(
                  settings.darkTheme,
                ),

                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}