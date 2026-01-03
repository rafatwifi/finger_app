import 'roles.dart';
import 'permissions.dart';

const Map<UserRole, Set<Permission>> rolePermissions = {
  UserRole.admin: {
    Permission.viewEmployees,
    Permission.approveAttendance,
    Permission.approveLeave,
    Permission.viewReports,
    Permission.manageUsers,
  },

  UserRole.manager: {
    Permission.viewEmployees,
    Permission.approveAttendance,
    Permission.approveLeave,
    Permission.viewReports,
  },

  UserRole.supervisor: {Permission.viewEmployees, Permission.approveAttendance},

  UserRole.employee: {},
};
