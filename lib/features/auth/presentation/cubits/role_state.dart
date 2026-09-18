import 'package:my_resturant/features/auth/domain/entities/role.dart';

/// Immutable state of the role session: which [Role] is active on this device
/// and how far the account got through setup / login.
class RoleState {
  final Role role;
  final bool isConfigured;
  final bool isLoggedIn;
  final String? errorMessage;

  const RoleState({
    this.role = Role.admin,
    this.isConfigured = false,
    this.isLoggedIn = false,
    this.errorMessage,
  });
}