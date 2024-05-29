import 'package:flutter/material.dart';

class TestamentScreen extends StatelessWidget {
  
  final String testament;
  const TestamentScreen({super.key, required this.testament});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(testament),
      ),
      body: Center(
        child: Text('Display books of the $testament here'),
      ),
    );
  }
}