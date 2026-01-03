import 'package:flutter/material.dart';
import '../../core/utils/permission_guard.dart';
import '../../core/constants/permissions.dart';
import '../../data/repositories/attendance_repository.dart';

class SupervisorAttendanceQueue extends StatelessWidget {
  const SupervisorAttendanceQueue({super.key});

  @override
  Widget build(BuildContext context) {
    // منع الوصول إذا ما عنده صلاحية اعتماد
    if (!PermissionGuard.can(Permission.approveAttendance)) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('FORBIDDEN', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    // مستودع الحضور
    final repo = AttendanceRepository();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pending Attendance'),
        backgroundColor: Colors.black,
      ),

      // جلب البصمات المعلقة مباشرة من Firestore
      body: StreamBuilder(
        stream: repo.pending(),
        builder: (context, snap) {
          // أثناء التحميل
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final records = snap.data!;

          // لا توجد بصمات معلقة
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'NO PENDING ATTENDANCE',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // عرض قائمة البصمات
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];

              return Card(
                color: Colors.grey.shade900,
                child: ListTile(
                  title: Text(
                    r.userId,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    r.timestamp.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر اعتماد
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => repo.approve(r.id),
                      ),
                      // زر رفض
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => repo.reject(r.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
