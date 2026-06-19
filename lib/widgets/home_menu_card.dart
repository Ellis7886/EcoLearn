import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';

class HomeMenuCard extends StatelessWidget {

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const HomeMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final settings =
    Provider.of<AppSettings>(context);

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(
          bottom: 20,
        ),

        decoration: BoxDecoration(

          color: AppColors.card(
            settings.darkTheme,
          ),

          borderRadius:
          BorderRadius.circular(20),

          boxShadow:
          settings.darkTheme

              ? []

              : [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(
              padding:
              const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.15),

                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: Icon(
                icon,
                color: AppColors.primary,
                size: 34,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: TextStyle(
                      color:
                      AppColors.text(
                        settings.darkTheme,
                      ),

                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    description,

                    style: TextStyle(
                      color:
                      AppColors.subText(
                        settings.darkTheme,
                      ),

                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,

              color:
              AppColors.subText(
                settings.darkTheme,
              ),

              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}