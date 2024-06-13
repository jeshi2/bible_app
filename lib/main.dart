import 'package:flutter/material.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: RoundedRectangle(),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to the Bible App!'),
      ),
    );
  }
}

// Top navigation
class RoundedRectangle extends StatelessWidget {
  const RoundedRectangle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Sidebar icon
            Icon(Icons.menu, color: Colors.grey), 
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Version',
                      style: TextStyle(color: Colors.black),
                    ),
                    // Drop-down icon
                    Icon(Icons.arrow_drop_down,
                        color: Colors.grey), 
                  ],
                ),
              ),
            ),
            // Search icon
            Icon(Icons.search, color: Colors.grey), 
          ],
        ),
      ),
    );
  }
}
