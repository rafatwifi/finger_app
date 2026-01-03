import '../models/user_model.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  @override
  Future<UserModel?> getById(String id) async {
    return null;
  }

  @override
  Future<List<UserModel>> getAll() async {
    return [];
  }

  @override
  Future<void> create(UserModel user) async {}

  @override
  Future<void> update(UserModel user) async {}

  @override
  Future<void> delete(String id) async {}
}
