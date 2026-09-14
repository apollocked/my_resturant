enum Role { waiter, kitchen, admin }

extension RoleExtension on Role {
  String get key => name;
  static Role fromKey(String key) => Role.values.firstWhere((r) => r.name == key, orElse: () => Role.waiter);
}
