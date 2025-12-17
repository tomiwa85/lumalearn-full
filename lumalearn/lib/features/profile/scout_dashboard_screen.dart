import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';
import 'package:intl/intl.dart';

// Provider to fetch linked students
final linkedStudentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(chatServiceProvider).getLinkedStudents();
});

class ScoutDashboardScreen extends ConsumerWidget {
  const ScoutDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(linkedStudentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text("Scout Dashboard"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text("No students linked yet.",
                  style: TextStyle(color: AppTheme.textGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['student_id'];
              final userData =
                  student['users'] as Map<String, dynamic>; // Joined data
              final name = userData['full_name'] ?? 'Unknown Student';

              return _StudentCard(studentId: studentId, studentName: name);
            },
          );
        },
      ),
      // General School Guide Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.neonGreen,
        onPressed: () {
          // Open General Chat about School
          context.push('/session', extra: {
            'id': null, // New session
            'subject': 'General',
          });
        },
        icon: const Icon(Icons.info_outline, color: Colors.black),
        label:
            const Text("School Guide", style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

class _StudentCard extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const _StudentCard({required this.studentId, required this.studentName});

  @override
  ConsumerState<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends ConsumerState<_StudentCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceGrey,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.neonGreen.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppTheme.neonGreen),
            ),
            title: Text(widget.studentName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Student Profile",
                style: TextStyle(color: AppTheme.textGrey)),
          ),

          const Divider(color: Colors.white10),

          // ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 1. ASK ADVISOR (Persistent Chat)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Fetch latest Persistent ID for Parent Mode
                        final chatService = ref.read(chatServiceProvider);
                        final lastSessionId =
                            await chatService.getLatestSessionId("Parent");

                        if (context.mounted) {
                          context.push('/session', extra: {
                            'id':
                                lastSessionId, // Pass ID if exists, triggering resume
                            'subject': 'Parent',
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                      label: const Text("Ask Advisor",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. VIEW HISTORY
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/scout-student-history', extra: {
                          'studentId': widget.studentId,
                          'studentName': widget.studentName,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.history, size: 20),
                      label: const Text("View History",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Ask questions like:\n• \"How is he doing in Math?\"\n• \"What did she learn yesterday?\"",
              style: TextStyle(
                  color: AppTheme.textGrey, height: 1.4, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
