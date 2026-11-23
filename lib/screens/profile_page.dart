import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/local_user_service.dart';

import '../themes/app_colors.dart';

import '../provider/app_settings.dart';

import '../models/user.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/setting_switch.dart';

import 'security/login_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<Map<String, dynamic>?>? userFuture;

  bool? _lastEcoMode;

  Future<Map<String, dynamic>?> loadUser(
      bool ecoMode) async {

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return null;
    }

    // ==========================
    // ECO MODE
    // ==========================

    if (ecoMode) {

      final local =
      await LocalUserService().getUser();

      debugPrint('LOCAL USER: $local');

      if (local['name'] == null ||
          local['name']!.isEmpty) {
        return null;
      }

      return {
        'name': local['name'] ?? '',
        'email': local['email'] ?? '',
        'role': local['role'] ?? '',
      };
    }

    // ==========================
    // NORMAL MODE
    // ==========================

    final snapshot =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settings = Provider.of<AppSettings>(
      context,
      listen: false,
    );

    if (_lastEcoMode == settings.ecoMode) {
      return;
    }

    _lastEcoMode = settings.ecoMode;

    userFuture = loadUser(settings.ecoMode);
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: AppColors.background(
        settings.darkTheme,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index){},
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background(
          settings.darkTheme,
        ),
        elevation: 0,

        iconTheme: IconThemeData(
          color: AppColors.text(
            settings.darkTheme,
          ),
        ),

        title: Consumer<AppSettings>(
          builder: (context, settings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Profile'),
                Text(
                  settings.ecoMode ? 'ECO MODE' : 'NORMAL MODE',
                  style: TextStyle(
                    color: settings.ecoMode
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,

        builder: (context, snapshot) {

          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null) {

            return const Center(
              child: Text(
                'User data not found',
              ),
            );
          }

          final user = UserModel.fromFirestore(
            snapshot.data!,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: AppColors.card(
                        settings.darkTheme,
                      ),

                      borderRadius: BorderRadius.circular(25),

                      boxShadow: settings.darkTheme ? [] : [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        const CircleAvatar(
                          radius: 55,
                          backgroundColor: AppColors.primary,

                          child: Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          user.name,
                          style: TextStyle(
                            color: AppColors.text(
                              settings.darkTheme,
                            ),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          user.email,
                          style: TextStyle(
                            color: AppColors.subText(
                              settings.darkTheme,
                            ),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.text(
                        settings.darkTheme,
                      ),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SettingSwitch(
                    title: 'Eco Mode',
                    description: 'Optimize performance and save energy',
                    icon: Icons.eco,
                    value: settings.ecoMode,
                    onChanged: settings.toggleEcoMode,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {

                        final authService = AuthService();

                        await authService.logout();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}