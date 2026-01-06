import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupervisorAttendanceQueue extends StatelessWidget {
  const SupervisorAttendanceQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pending Attendance'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // بث حي من فايربيس – أي تغيير ينعكس فوراً
        stream: FirebaseFirestore.instance
            .collection('attendance_records')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snap) {
          // أثناء التحميل
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          // إذا ماكو بيانات
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text('NO PENDING', style: TextStyle(color: Colors.grey)),
            );
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];

              return ListTile(
                title: Text(
                  d['userId'],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر قبول
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        // تحديث الحالة إلى approved
                        await d.reference.update({'status': 'approved'});
                      },
                    ),
                    // زر رفض
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        // تحديث الحالة إلى rejected
                        await d.reference.update({'status': 'rejected'});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
