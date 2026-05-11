import 'package:flutter/material.dart';

class EcoMode extends StatefulWidget {
  const EcoMode({super.key});

  @override
  State<EcoMode> createState() => _EcoModeState();
}

class _EcoModeState extends State<EcoMode> {

  bool isEcoMode = true;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          const Icon(
            Icons.eco,
            color: Color(0xFF9BD028),
            size: 45,
          ),

          const SizedBox(width: 20),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  'Eco Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Optimize performance and save energy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.7,

            child: Switch(
              value: isEcoMode,

              onChanged: (value) {
                setState(() {
                  isEcoMode = value;
                });
              },

              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF9BD028),
            ),
          ),
        ],
      ),
    );
  }
}