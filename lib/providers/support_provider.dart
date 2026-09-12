import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TicketStatus { open, inProgress, resolved }

enum TicketPriority { low, medium, high }

class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    this.priority = TicketPriority.medium,
    this.status = TicketStatus.open,
    required this.createdAt,
  });

  SupportTicket copyWith({
    String? subject,
    String? description,
    String? category,
    TicketPriority? priority,
    TicketStatus? status,
  }) =>
      SupportTicket(
        id: id,
        subject: subject ?? this.subject,
        description: description ?? this.description,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}

class TicketsNotifier extends StateNotifier<List<SupportTicket>> {
  TicketsNotifier() : super([]);

  void add(SupportTicket ticket) {
    state = [ticket, ...state];
  }

  void updateStatus(String id, TicketStatus status) {
    state = state
        .map((t) => t.id == id ? t.copyWith(status: status) : t)
        .toList();
  }
}

final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, List<SupportTicket>>(
  (ref) => TicketsNotifier(),
);
