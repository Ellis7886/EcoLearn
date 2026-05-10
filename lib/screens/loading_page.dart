import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/ecolearn_logo.png',
              height: 180,
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(
              color: Color(0xFF9BD028),
            ),

            const SizedBox(height: 20),

            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}