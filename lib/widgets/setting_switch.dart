import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';

class SettingSwitch extends StatelessWidget {

  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(
        bottom: 15,
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
            blurRadius: 8,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: AppColors.primary,
            size: 40,
          ),

          const SizedBox(width: 15),

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

                const SizedBox(height: 5),

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

          Transform.scale(
            scale: 0.6,

            child: Switch(
              value: value,
              onChanged: onChanged,

              activeThumbColor:
              Colors.white,

              activeTrackColor:
              AppColors.primary,

              inactiveThumbColor:
              Colors.white,

              inactiveTrackColor:
              Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}