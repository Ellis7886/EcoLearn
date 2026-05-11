import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/home_menu_card.dart';
import '../widgets/eco_mode_switch.dart';
import '../widgets/bottom_nav_bar.dart';
import'../models/lesson.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      bottomNavigationBar: BottomNavBar(
          currentIndex: 0,
          onTap: (index){},
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Center(
                  child: Image.asset(
                    'assets/images/ecolearn_logo.png',
                    height: 230,
                  ),
                ),

                const EcoMode(),

                const SizedBox(height: 20),

                Text(
                  'Main Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                HomeMenuCard(
                    title: 'Lessons',
                    description: 'Access Learning materials',
                    icon: Icons.menu_book_rounded,
                    onTap: (){},
                ),

                HomeMenuCard(
                    title: 'Resources',
                    description: 'Explore learning resources',
                    icon: Icons.folder_rounded,
                    onTap: (){},
                ),

                HomeMenuCard(
                    title: 'Quiz',
                    description: 'Test your knowledge',
                    icon: Icons.quiz_rounded,
                    onTap: (){},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}