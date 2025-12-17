import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';

class ScoutStudentHistoryScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;

  const ScoutStudentHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scoutHistoryProvider(studentId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text("$studentName's Activity"),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: historyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
                child: Text("No activity found.",
                    style: TextStyle(color: AppTheme.textGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  title: Text(session.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "${session.subject} • ${DateFormat('MMM d, h:mm a').format(session.createdAt)}",
                      style: const TextStyle(
                          color: AppTheme.textGrey, fontSize: 12)),
                  trailing:
                      const Icon(Icons.visibility, color: AppTheme.neonGreen),
                  onTap: () {
                    // Open Session in Read-Only Mode
                    context.push('/session', extra: {
                      'id': session.id,
                      'subject': session.subject,
                    });
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

final scoutHistoryProvider = FutureProvider.autoDispose
    .family<List<ChatSession>, String>((ref, studentId) async {
  return ref.read(chatServiceProvider).getStudentSessions(studentId);
});
