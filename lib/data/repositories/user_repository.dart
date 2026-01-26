import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getById(String id);
  Future<List<UserModel>> getAll();
  Future<void> create(UserModel user);
  Future<void> update(UserModel user);
  Future<void> delete(String id);
}
