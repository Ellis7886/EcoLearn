import 'package:flutter/material.dart';

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

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 20),

        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(5),

              child: Icon(
                icon,
                color: const Color(0xFF9BD028),
                size: 40,
              ),
            ),

            const SizedBox(width: 25),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

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
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}