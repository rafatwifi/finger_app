import '../constants/permissions.dart';
import '../constants/role_permissions.dart';
import '../services/app_user_state.dart';

class PermissionGuard {
  static bool can(Permission permission) {
    final user = AppUserState.user;
    if (user == null) return false;

    return rolePermissions[user.role]?.contains(permission) ?? false;
  }
}
