import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'ADMIN HOME',
          style: TextStyle(color: Colors.green, fontSize: 22),
        ),
      ),
    );
  }
}
