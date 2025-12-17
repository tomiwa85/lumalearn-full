import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';

class TeacherStudentHistoryScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  final String subject;

  const TeacherStudentHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Using a Record (id: ..., subject: ...) instead of a Map
    // This stops the infinite reloading loop.
    final historyAsync = ref.watch(
      teacherSubjectHistoryProvider((id: studentId, subject: subject)),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text("$studentName - $subject"),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: historyAsync.when(
        // LOADING
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),

        // ERROR
        error: (err, stack) {
          print("UI ERROR: $err"); // Log to console
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text('Error: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)
                ),
                TextButton(
                  onPressed: () => ref.refresh(
                      teacherSubjectHistoryProvider((id: studentId, subject: subject))
                  ),
                  child: const Text("Retry", style: TextStyle(color: AppTheme.neonGreen)),
                )
              ],
            ),
          );
        },

        // DATA
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("No chats found.", style: TextStyle(color: AppTheme.textGrey)));
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
                  title: Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      DateFormat('MMM d, h:mm a').format(session.createdAt),
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)
                  ),
                  trailing: const Icon(Icons.visibility, color: AppTheme.neonGreen),
                  onTap: () {
                    context.push('/session', extra: {'subject': subject, 'id': session.id});
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

// --- FIXED PROVIDER (Using Records) ---

// Notice the type is `({String id, String subject})` NOT `Map<String, String>`
final teacherSubjectHistoryProvider = FutureProvider.autoDispose.family<List<ChatSession>, ({String id, String subject})>((ref, params) async {

  print("PROVIDER CALLED for ${params.subject}..."); // DEBUG LOG

  final chatService = ref.watch(chatServiceProvider);

  // Call the service
  return chatService.getStudentSessionsBySubject(params.id, params.subject);
});