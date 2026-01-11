import 'package:flutter/material.dart';
import '../../core/services/app_user_state.dart';
import '../../core/constants/roles.dart';
import '../employee/employee_attendance.dart';
import '../supervisor/attendance_queue.dart';
import '../home/admin_home.dart';
import '../shared/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // حماية: المستخدم قد يكون null أثناء الإقلاع
    final user = AppUserState.user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final role = user.role;

    // الصفحات (دائماً عنصرين على الأقل)
    final pages = <Widget>[
      if (role == UserRole.employee) const EmployeeAttendanceScreen(),
      if (role == UserRole.supervisor) const SupervisorAttendanceQueue(),
      if (role == UserRole.admin) const AdminHome(),

      // صفحة ثانية ثابتة للجميع (بروفايل / إعدادات)
      const ProfileScreen(),
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

        // لازم عنصرين على الأقل دائماً
        items: [
          if (role == UserRole.employee)
            const BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint),
              label: 'Attendance',
            ),
          if (role == UserRole.supervisor)
            const BottomNavigationBarItem(
              icon: Icon(Icons.fact_check),
              label: 'Approve',
            ),
          if (role == UserRole.admin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Admin',
            ),

          // العنصر الثاني الثابت
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
