import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/demo_data.dart';

class ChatNotifier extends StateNotifier<List<Conversation>> {
  ChatNotifier() : super(DemoData.conversations);

  void sendMessage(String conversationId, String senderId, String content) {
    state = [
      for (final conv in state)
        if (conv.id == conversationId)
          Conversation(
            id: conv.id,
            worker: conv.worker,
            messages: [
              ...conv.messages,
              MessageModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: senderId,
                content: content,
                timestamp: DateTime.now(),
              ),
            ],
          )
        else
          conv,
    ];
  }

  void startConversation(WorkerModel worker, String userId) {
    final exists = state.any((c) => c.worker.id == worker.id);
    if (!exists) {
      state = [
        Conversation(
          id: 'c_${worker.id}',
          worker: worker,
          messages: [
            MessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: worker.id,
              content: 'مرحباً! كيف يمكنني مساعدتك؟',
              timestamp: DateTime.now(),
            ),
          ],
        ),
        ...state,
      ];
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Conversation>>(
  (ref) => ChatNotifier(),
);
