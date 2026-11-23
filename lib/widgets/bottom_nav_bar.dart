import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';
import '../helpers/tab_route.dart';

import '../screens/home_page.dart';
import '../screens/lesson/lessons_page.dart';
import '../screens/profile_page.dart';
import '../screens/quiz/quiz_page.dart';

class BottomNavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Container(

      decoration: BoxDecoration(

        color: AppColors.card(
          settings.darkTheme,
        ),

        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),

        boxShadow:
        settings.darkTheme

            ? []

            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(
              0,
              -2,
            ),
          ),
        ],
      ),

      child: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {

          onTap(index);

          // CHANGED: tab pages now open with tabRoute():
          // Normal Mode = fade + slide in the direction of the tab,
          // Eco Mode = no animation.
          const pages = <Widget>[
            HomePage(),
            LessonsPage(),
            QuizPage(),
            ProfilePage(),
          ];

          if (index < 0 || index >= pages.length) return;

          Navigator.push(
            context,
            tabRoute(
              page: pages[index],
              ecoMode: settings.ecoMode,
              fromIndex: currentIndex,
              toIndex: index,
            ),
          );
        },

        backgroundColor: Colors.transparent,

        elevation: 0,

        type: BottomNavigationBarType.fixed,

        selectedItemColor:
        AppColors.primary,

        unselectedItemColor:
        AppColors.subText(
          settings.darkTheme,
        ),

        selectedLabelStyle:
        const TextStyle(
          fontWeight:
          FontWeight.bold,
        ),

        showUnselectedLabels: true,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}