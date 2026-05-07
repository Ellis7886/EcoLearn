import 'package:flutter/material.dart';

void main() {
  runApp(const EcoLearnApp());
}

class EcoLearnApp extends StatelessWidget {
  const EcoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Center(
                  child: Image.asset('assets/images/ecolearn_logo.png', height:300)
                ),

                Container(
                  width: 400,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(20)
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Color(0xFF9BD028),
                        size:50,
                      ),

                      SizedBox(width:20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                              'Lessons',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          Text(
                            'Access learning materials',
                            style: TextStyle(color: Colors.white70)
                          )
                        ],
                      )
                    ],
                  )
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}