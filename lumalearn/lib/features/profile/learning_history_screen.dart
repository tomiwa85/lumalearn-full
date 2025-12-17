import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';

class LearningHistoryScreen extends ConsumerWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHistoryAsync = ref.watch(allUserHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text("Learning History"),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: allHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("You haven't started learning yet!", style: TextStyle(color: AppTheme.textGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                color: AppTheme.surfaceGrey,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.neonGreen.withOpacity(0.2),
                    child: Text(session.subject[0], style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${session.subject} • ${DateFormat('MMM d').format(session.createdAt)}", style: const TextStyle(color: AppTheme.textGrey)),
                  onTap: () {
                    context.push('/session', extra: {'subject': session.subject, 'id': session.id});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final allUserHistoryProvider = FutureProvider.autoDispose<List<ChatSession>>((ref) async {

  // 2. Change ref.read to ref.watch
  // This ensures that if the User ID changes (Login/Logout), this provider re-runs immediately.
  final chatService = ref.watch(chatServiceProvider);

  return chatService.getAllUserSessions();
});