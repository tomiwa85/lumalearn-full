import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the profile data provider
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (profileData) {
          final isTeacher = profileData['role'] == 'teacher';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 2. AVATAR SECTION
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceGrey,
                      border: Border.all(color: AppTheme.neonGreen, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(isTeacher ? Icons.school : Icons.person,
                        size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. USER INFO
                Text(
                  profileData['full_name'] ?? 'Unknown User',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: isTeacher
                          ? Colors.orangeAccent.withOpacity(0.2)
                          : Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isTeacher
                              ? Colors.orangeAccent
                              : Colors.blueAccent,
                          width: 1)),
                  child: Text(
                    isTeacher
                        ? "Teacher Account"
                        : (profileData['role'] == 'scout'
                            ? "Parent Account"
                            : "Student Account"),
                    style: TextStyle(
                        color:
                            isTeacher ? Colors.orangeAccent : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),

                const SizedBox(height: 30),

                // 4. TEACHER SPECIFIC CARD (CLASS CODE)
                if (isTeacher && profileData['class_code'] != null)
                  _ClassCodeCard(
                    code: profileData['class_code'],
                    className: profileData['class_name'] ?? "Your Class",
                    titleText: "Share with Students",
                  ),

                // 4b. STUDENT SPECIFIC CARD (STUDENT CODE)
                if (!isTeacher && profileData['student_code'] != null)
                  _ClassCodeCard(
                    code: profileData['student_code'],
                    className: "Parent Access Code",
                    titleText: "Share with Parent",
                  ),

                // 5. STUDENT SPECIFIC INFO
                if (!isTeacher)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ENROLLED IN",
                            style: TextStyle(
                                color: AppTheme.textGrey, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          profileData['class_name'] ?? "Not Enrolled",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 6. MENU ITEMS
                if (isTeacher)
                  _ProfileMenuItem(
                      icon: Icons.people_outline,
                      text: "Manage Students",
                      onTap: () {
                        context.push('/manage-students');
                      }),

                // --- REMOVED "Learning History" BUTTON HERE ---

                const SizedBox(height: 40),

                // 7. SIGN OUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text("Sign Out"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

class _ClassCodeCard extends StatelessWidget {
  final String code;
  final String className;
  final String titleText; // New parameter

  const _ClassCodeCard(
      {required this.code, required this.className, required this.titleText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.neonGreen.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(className.toUpperCase(),
              style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          Text(titleText, // Use parameter
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Class code copied!"),
                    duration: Duration(milliseconds: 1000)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(code,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(width: 12),
                  const Icon(Icons.copy, color: AppTheme.neonGreen, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textGrey),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// --- PROVIDER LOGIC ---
final userProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value?.session?.user ??
      ref.read(authServiceProvider).currentUser;

  if (user == null) {
    throw Exception("No user logged in");
  }

  final supabase = Supabase.instance.client;

  final userData = await supabase
      .from('users')
      .select('full_name, role, enrolled_class_id, student_code')
      .eq('id', user.id)
      .single();

  final role = userData['role'];
  Map<String, dynamic> result = {
    'full_name': userData['full_name'],
    'role': role,
    'student_code': userData['student_code'],
  };

  if (role == 'teacher') {
    final classData = await supabase
        .from('classes')
        .select('name, access_code')
        .eq('teacher_id', user.id)
        .maybeSingle();

    if (classData != null) {
      result['class_name'] = classData['name'];
      result['class_code'] = classData['access_code'];
    }
  } else {
    final classId = userData['enrolled_class_id'];
    if (classId != null) {
      final classData = await supabase
          .from('classes')
          .select('name')
          .eq('id', classId)
          .single();
      result['class_name'] = classData['name'];
    }
  }

  return result;
});
