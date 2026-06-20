import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';

class ResourceCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String description;
  final String chapter;
  final String fileName;
  final VoidCallback onOpen;

  const ResourceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.chapter,
    required this.fileName,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {

    final settings =
    Provider.of<AppSettings>(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      decoration: BoxDecoration(
        color: AppColors.card(
          settings.darkTheme,
        ),

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: settings.darkTheme
            ? []
            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),

        child: ExpansionTile(

          leading: Icon(
            icon,
            color: AppColors.primary,
            size: 35,
          ),

          iconColor: AppColors.text(
            settings.darkTheme,
          ),

          collapsedIconColor:
          AppColors.text(
            settings.darkTheme,
          ),

          title: Text(
            title,

            style: TextStyle(
              color: AppColors.text(
                settings.darkTheme,
              ),

              fontWeight:
              FontWeight.bold,

              fontSize: 18,
            ),
          ),

          childrenPadding:
          const EdgeInsets.all(16),

          children: [

            Align(
              alignment:
              Alignment.centerLeft,

              child: Text(
                description,

                style: TextStyle(
                  color:
                  AppColors.subText(
                    settings.darkTheme,
                  ),

                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Align(
              alignment:
              Alignment.centerLeft,

              child: Text(
                'Chapter: $chapter',

                style: const TextStyle(
                  color:
                  AppColors.primary,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Align(
              alignment:
              Alignment.centerLeft,

              child: Text(
                fileName,

                style: TextStyle(
                  color:
                  AppColors.subText(
                    settings.darkTheme,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton.icon(

                onPressed: onOpen,

                icon: const Icon(
                  Icons.open_in_new,
                ),

                label: const Text(
                  'Open Material',
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,

                  foregroundColor:
                  settings.darkTheme ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}