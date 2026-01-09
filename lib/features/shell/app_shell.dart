import 'package:flutter/material.dart';
import '../../core/services/app_user_state.dart';
import '../../core/constants/roles.dart';
import '../employee/employee_attendance.dart';
import '../supervisor/attendance_queue.dart';
import '../home/admin_home.dart';
import '../admin/polygon_editor.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final role = AppUserState.user!.role;

    /// الصفحات حسب الدور (دائمًا عنصرين على الأقل)
    final pages = <Widget>[
      if (role == UserRole.employee) const EmployeeAttendanceScreen(),
      if (role == UserRole.employee) const SizedBox(), // صفحة وهمية

      if (role == UserRole.supervisor) const SupervisorAttendanceQueue(),
      if (role == UserRole.supervisor) const SizedBox(),

      if (role == UserRole.admin) const AdminHome(),
      if (role == UserRole.admin) const PolygonEditorScreen(),
    ];

    /// عناصر البوتوم بار (دائمًا عنصرين)
    final items = <BottomNavigationBarItem>[
      if (role == UserRole.employee)
        const BottomNavigationBarItem(
          icon: Icon(Icons.fingerprint),
          label: 'Attendance',
        ),
      if (role == UserRole.employee)
        const BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'Info',
        ),

      if (role == UserRole.supervisor)
        const BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'Approve',
        ),
      if (role == UserRole.supervisor)
        const BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'Info',
        ),

      if (role == UserRole.admin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Admin',
        ),
      if (role == UserRole.admin)
        const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Area'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: items,
      ),
    );
  }
}
