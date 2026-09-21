import 'package:shared_preferences/shared_preferences.dart';

class LocalUserService {

  Future<void> saveUser({
    required String name,
    required String email,
    required String role,
  }) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_role', role);
  }

  Future<Map<String, String>> getUser() async {

    final prefs =
    await SharedPreferences.getInstance();

    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_role') ?? '',
    };
  }
}