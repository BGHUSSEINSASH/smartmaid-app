enum AppRole { customer, worker, admin, company }

extension AppRoleX on AppRole {
  String get arabicLabel {
    switch (this) {
      case AppRole.customer:
        return 'عميل';
      case AppRole.worker:
        return 'عاملة';
      case AppRole.admin:
        return 'مدير';
      case AppRole.company:
        return 'شركة';
    }
  }
}

AppRole appRoleFromBackend(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'worker':
      return AppRole.worker;
    case 'admin':
      return AppRole.admin;
    case 'company':
      return AppRole.company;
    case 'customer':
    default:
      return AppRole.customer;
  }
}
