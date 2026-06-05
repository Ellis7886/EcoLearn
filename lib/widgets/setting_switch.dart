import 'package:flutter/material.dart';

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

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: const Color(0xFF9BD028),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
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

              activeThumbColor: Colors.white,

              activeTrackColor:
              const Color(0xFF9BD028),

              inactiveThumbColor:
              Colors.white,

              inactiveTrackColor:
              Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}