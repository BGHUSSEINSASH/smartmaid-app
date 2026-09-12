import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuditAction {
  bookingCreated,
  bookingCancelled,
  bookingCompleted,
  paymentHeld,
  paymentReleased,
  workerStarted,
  sosTriggered,
  subscriptionChanged,
  profileUpdated,
  ticketCreated,
  withdrawalApproved,
  companyApproved,
  userDeactivated,
  sessionLogin,
  sessionLogout,
}

extension AuditActionX on AuditAction {
  String get label {
    switch (this) {
      case AuditAction.bookingCreated:
        return 'إنشاء حجز';
      case AuditAction.bookingCancelled:
        return 'إلغاء حجز';
      case AuditAction.bookingCompleted:
        return 'إتمام حجز';
      case AuditAction.paymentHeld:
        return 'حفظ الدفع';
      case AuditAction.paymentReleased:
        return 'تحرير الدفع';
      case AuditAction.workerStarted:
        return 'بدء المهمة';
      case AuditAction.sosTriggered:
        return 'تنبيه طوارئ';
      case AuditAction.subscriptionChanged:
        return 'تغيير اشتراك';
      case AuditAction.profileUpdated:
        return 'تحديث ملف شخصي';
      case AuditAction.ticketCreated:
        return 'إنشاء تذكرة دعم';
      case AuditAction.withdrawalApproved:
        return 'موافقة سحب';
      case AuditAction.companyApproved:
        return 'موافقة شركة';
      case AuditAction.userDeactivated:
        return '????? ??????';
      case AuditAction.sessionLogin:
        return 'تسجيل دخول';
      case AuditAction.sessionLogout:
        return 'تسجيل خروج';
    }
  }

  String get icon {
    switch (this) {
      case AuditAction.bookingCreated:
        return '📌';
      case AuditAction.bookingCancelled:
        return '❌';
      case AuditAction.bookingCompleted:
        return '✅';
      case AuditAction.paymentHeld:
        return '🔒';
      case AuditAction.paymentReleased:
        return '🔓';
      case AuditAction.workerStarted:
        return '🚀';
      case AuditAction.sosTriggered:
        return '🚨';
      case AuditAction.subscriptionChanged:
        return '⭐';
      case AuditAction.profileUpdated:
        return '👤';
      case AuditAction.ticketCreated:
        return '🎫';
      case AuditAction.withdrawalApproved:
        return '💰';
      case AuditAction.companyApproved:
        return '🏢';
      case AuditAction.userDeactivated:
        return '??';
      case AuditAction.sessionLogin:
        return '🔓';
      case AuditAction.sessionLogout:
        return '🚪';
    }
  }
}

class AuditLogEntry {
  final String id;
  final AuditAction action;
  final String description;
  final String? userId;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.description,
    this.userId,
    required this.timestamp,
  });
}

class AuditLogNotifier extends StateNotifier<List<AuditLogEntry>> {
  AuditLogNotifier() : super([]);

  void log(AuditAction action, String description, {String? userId}) {
    state = [
      AuditLogEntry(
        id: 'al_${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        description: description,
        userId: userId,
        timestamp: DateTime.now(),
      ),
      ...state,
    ];
  }
}

final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, List<AuditLogEntry>>(
  (ref) => AuditLogNotifier(),
);
