import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/roles.dart';

class FirestoreUserRepositoryImpl {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getOrCreateUser({
    required String uid,
    required String email,
  }) async {
    try {
      final ref = _db.collection('users').doc(uid);
      final snap = await ref.get();

      if (snap.exists) {
        final data = snap.data()!;
        return UserModel(
          id: uid,
          fullName: data['fullName'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          departmentId: data['departmentId'] ?? '',
          role: UserRole.values.byName((data['role'] ?? 'employee').toString()),
        );
      }

      final user = UserModel(
        id: uid,
        fullName: 'NEW USER',
        phone: '',
        email: email,
        departmentId: '',
        role: UserRole.employee,
      );

      await ref.set({
        'fullName': user.fullName,
        'phone': user.phone,
        'email': user.email,
        'departmentId': user.departmentId,
        'role': user.role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      throw Exception('Firestore user init failed: $e');
    }
  }
}
