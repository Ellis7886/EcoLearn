import 'package:flutter/material.dart';

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

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF9BD028),
                  size: 45,
                ),

                const SizedBox(width: 15),

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
                        courseCode,
                        style: const TextStyle(
                          color: Color(0xFF9BD028),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,

                backgroundColor: Colors.white24,
                color: const Color(0xFF9BD028),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,

              child: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}