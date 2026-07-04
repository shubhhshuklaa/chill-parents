import 'package:flutter/material.dart';

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Children",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}