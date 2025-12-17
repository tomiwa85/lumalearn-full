import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';
import 'package:intl/intl.dart';

class StudentDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> studentData; // Contains 'id' and 'full_name'

  const StudentDetailScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = studentData['id'];
    final sessionsAsync = ref.watch(studentSessionsProvider(studentId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text(studentData['full_name'] ?? 'Student Info'),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("No activity yet.", style: TextStyle(color: AppTheme.textGrey)));
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
                  title: Text(session.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${session.subject} • ${DateFormat('MMM d').format(session.createdAt)}", style: const TextStyle(color: AppTheme.textGrey)),
                  trailing: const Icon(Icons.visibility, color: AppTheme.neonGreen),
                  onTap: () {
                    // Open the chat in Read-Only mode (we can reuse SessionScreen)
                    context.push('/session', extra: {
                      'subject': session.subject,
                      'id': session.id,
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

// Provider to fetch specific student history
final studentSessionsProvider = FutureProvider.family<List<ChatSession>, String>((ref, studentId) async {
  return ref.read(chatServiceProvider).getStudentSessions(studentId);
});