import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/lessons_page.dart';
import '../screens/profile_page.dart';

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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),

      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index){

          onTap(index);

          if(index == 0){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }else if(index == 1){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LessonsPage(),
              ),
            );
          }else if(index == 4){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },

        backgroundColor: Colors.transparent,
        elevation: 0,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF9BD028),
        unselectedItemColor: Colors.white54,

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
            icon: Icon(Icons.folder),
            label: 'Resources',
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