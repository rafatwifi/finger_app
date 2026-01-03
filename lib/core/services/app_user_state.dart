import '../../data/models/user_model.dart';

class AppUserState {
  static UserModel? _user;

  static UserModel? get user => _user;

  static void set(UserModel user) {
    _user = user;
  }

  static void clear() {
    _user = null;
  }
}
