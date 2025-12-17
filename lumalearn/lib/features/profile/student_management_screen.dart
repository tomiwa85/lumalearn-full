import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';

class StudentManagementScreen extends ConsumerWidget {
  const StudentManagementScreen({super.key});

  // Function to remove student
  // Function to PERMANENTLY delete student
  Future<void> _removeStudent(BuildContext context, WidgetRef ref, String studentId, String studentName) async {
    // 1. Show Warning Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        title: const Text("Delete Account?", style: TextStyle(color: Colors.white)),
        content: Text(
            "WARNING: This will permanently delete $studentName's account, including their email, password, and all chat history.\n\nThey will no longer be able to log in.",
            style: const TextStyle(color: AppTheme.textGrey)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Call the Secure Database Function
    try {
      final supabase = Supabase.instance.client;

      // Call the SQL function we just created
      await supabase.rpc('delete_student_account', params: {
        'target_user_id': studentId
      });

      // 3. Refresh the list immediately
      ref.refresh(classStudentsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$studentName's account has been deleted."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting user: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(classStudentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text("No students enrolled yet.", style: TextStyle(color: AppTheme.textGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.neonGreen.withOpacity(0.2),
                    child: Text(
                      student['full_name'][0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    student['full_name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Student", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),

                  // --- ROW with DELETE BUTTON ---
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View History Arrow
                      const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
                      const SizedBox(width: 16),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeStudent(context, ref, student['id'], student['full_name']),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Student Subjects
                    context.push('/student-subjects', extra: student);
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

// --- PROVIDER ---
final classStudentsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return [];

  final supabase = Supabase.instance.client;

  // 1. Get Teacher's Class ID
  final classData = await supabase
      .from('classes')
      .select('id')
      .eq('teacher_id', user.id)
      .maybeSingle();

  if (classData == null) return [];

  // 2. Get Students in that Class (FIXED: Removed 'email' from select)
  final students = await supabase
      .from('users')
      .select('id, full_name') // <--- REMOVED 'email' HERE
      .eq('enrolled_class_id', classData['id']);

  return List<Map<String, dynamic>>.from(students);
});