import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';

import '../themes/app_colors.dart';

import '../widgets/home_menu_card.dart';
import '../widgets/setting_switch.dart';
import '../widgets/bottom_nav_bar.dart';

import 'lesson/lessons_page.dart';
import 'resource/resources_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor:
      AppColors.background(
        settings.darkTheme,
      ),

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
                    settings.darkTheme ? 'assets/images/ecolearn_logo.png' : 'assets/images/ecolearn_logo_light_theme.png',
                    height: 230,
                  ),
                ),

                SettingSwitch(
                  title: 'Eco Mode',
                  description: 'Optimize performance and save energy',
                  icon: Icons.eco,
                  value: settings.ecoMode,
                  onChanged: settings.toggleEcoMode,
                ),

                SettingSwitch(
                  title: 'Dark Theme',
                  description: 'Reduce brightness for better comfort',
                  icon: Icons.dark_mode,
                  value: settings.darkTheme,
                  onChanged: settings.toggleDarkTheme,
                ),

                const SizedBox(height: 20),

                Text(
                  'Main Menu',
                  style: TextStyle(
                    color: AppColors.text(
                      settings.darkTheme,
                    ),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                HomeMenuCard(
                  title: 'Lessons',
                  description: 'Access learning materials',
                  icon: Icons.menu_book_rounded,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const LessonsPage(),
                      ),
                    );
                  },
                ),

                HomeMenuCard(
                  title: 'Resources',
                  description: 'Explore learning resources',
                  icon: Icons.folder_rounded,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ResourcesPage(),
                      ),
                    );
                  },
                ),

                HomeMenuCard(
                  title: 'Quiz',
                  description: 'Test your knowledge',
                  icon: Icons.quiz_rounded,
                  onTap: (){

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}