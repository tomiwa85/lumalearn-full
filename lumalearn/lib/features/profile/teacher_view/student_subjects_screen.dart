import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';

class StudentSubjectsScreen extends ConsumerWidget {
  final Map<String, dynamic> studentData; // {'id': '...', 'full_name': '...'}

  const StudentSubjectsScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = studentData['id'];
    // Reusing the "get all sessions" provider to calculate subjects locally
    final allSessionsAsync = ref.watch(studentSessionsProvider(studentId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text("${studentData['full_name']}'s Subjects"),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: allSessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("No activity yet.", style: TextStyle(color: AppTheme.textGrey)));
          }

          // LOGIC: Extract unique subjects from the history list
          final uniqueSubjects = sessions.map((s) => s.subject).toSet().toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uniqueSubjects.length,
            itemBuilder: (context, index) {
              final subject = uniqueSubjects[index];
              // Count how many chats in this subject
              final count = sessions.where((s) => s.subject == subject).length;

              return Card(
                color: AppTheme.surfaceGrey,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_open, color: AppTheme.neonGreen),
                  ),
                  title: Text(subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("$count sessions", style: const TextStyle(color: AppTheme.textGrey)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  onTap: () {
                    // Navigate to the filtered history list
                    context.push('/teacher-student-history', extra: {
                      'studentId': studentId,
                      'studentName': studentData['full_name'],
                      'subject': subject,
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
final studentSessionsProvider = FutureProvider.family<List<ChatSession>, String>((ref, studentId) async {
  // Use the new getStudentSessions method we just added to ChatService
  return ref.read(chatServiceProvider).getStudentSessions(studentId);
});