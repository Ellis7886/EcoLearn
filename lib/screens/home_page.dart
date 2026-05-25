import 'package:flutter/material.dart';

import '../widgets/home_menu_card.dart';
import '../widgets/setting_switch.dart';
import '../widgets/bottom_nav_bar.dart';

import '../screens/lessons_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  bool ecoMode = true;
  bool darkTheme = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      darkTheme ? Colors.black : Colors.white,

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index){},
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Center(
                  child: Image.asset(
                    'assets/images/ecolearn_logo.png',
                    height: 230,
                  ),
                ),

                SettingSwitch(
                  title: 'Eco Mode',
                  description:
                  'Optimize performance and save energy',

                  icon: Icons.eco,

                  initialValue: ecoMode,

                  onChanged: (value){

                    setState(() {
                      ecoMode = value;
                    });

                    print('Eco Mode: $value');
                  },
                ),

                SettingSwitch(
                  title: 'Dark Theme',
                  description:
                  'Reduce brightness for better comfort',

                  icon: Icons.dark_mode,

                  initialValue: darkTheme,

                  onChanged: (value){

                    setState(() {
                      darkTheme = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Main Menu',
                  style: TextStyle(
                    color: darkTheme
                        ? Colors.white
                        : Colors.black,

                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                HomeMenuCard(
                  title: 'Lessons',
                  description:
                  'Access learning materials',

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
                  description:
                  'Explore learning resources',

                  icon: Icons.folder_rounded,

                  onTap: (){},
                ),

                HomeMenuCard(
                  title: 'Quiz',
                  description:
                  'Test your knowledge',

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