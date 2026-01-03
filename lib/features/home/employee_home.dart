import 'package:flutter/material.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'EMPLOYEE HOME',
          style: TextStyle(color: Colors.green, fontSize: 22),
        ),
      ),
    );
  }
}
