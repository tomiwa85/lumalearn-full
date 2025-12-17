import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helper function to generate a unique 6-digit class code (e.g., LRN-1234)
String _generateClassCode() {
  final random = DateTime.now().millisecondsSinceEpoch % 100000;
  return 'LRN-${random.toString().padLeft(4, '0')}';
}

// Helper for Student Code (e.g., STU-5678)
String _generateStudentCode() {
  final random = (DateTime.now().millisecondsSinceEpoch / 2).round() % 100000;
  return 'STU-${random.toString().padLeft(4, '0')}';
}

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  // New extended sign-up function
  Future<void> signUpAndProfile({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? accessCode, // Class/Teacher Code
    String? studentCode, // For Scouts to link to a student
  }) async {
    // 1. Sign up the user in Supabase auth.users table
    await _supabase.auth.signUp(email: email, password: password);
    final user = currentUser;

    if (user == null) {
      throw Exception("User creation failed after sign up.");
    }

    try {
      // --- Conditional Logic based on Role ---
      String finalRole = role;
      String? classIdToEnroll;
      String? generatedStudentCode;

      if (role == 'teacher') {
        // 2a. TEACHER: Create a new class
        final newClassCode = _generateClassCode();
        await _supabase.from('classes').insert({
          'teacher_id': user.id,
          'access_code': newClassCode,
          'name': '$fullName\'s Class',
          'subject': 'General',
        });
      } else if (role == 'student') {
        // 2b. STUDENT: Validate access code and generate unique student code
        if (accessCode == null || accessCode.isEmpty) {
          throw Exception("Student enrollment requires a valid Access Code.");
        }

        final List<Map<String, dynamic>> classes = await _supabase
            .from('classes')
            .select('id')
            .eq('access_code', accessCode.toUpperCase())
            .limit(1);

        if (classes.isEmpty)
          throw Exception("Invalid Class Access Code: $accessCode");
        classIdToEnroll = classes.first['id'] as String;

        // Generate code for parents to use
        generatedStudentCode = _generateStudentCode();
      } else if (role == 'scout') {
        // 2c. SCOUT (Parent): Validate BOTH codes
        if (accessCode == null || studentCode == null) {
          throw Exception("Scouts need both Class Code and Student Code.");
        }

        // Validate Class (Teacher's Code)
        final classes = await _supabase
            .from('classes')
            .select('id')
            .eq('access_code', accessCode.toUpperCase())
            .limit(1);
        if (classes.isEmpty) throw Exception("Invalid Class Code.");

        // Validate Student
        final students = await _supabase
            .from('users')
            .select('id')
            .eq('student_code', studentCode.toUpperCase())
            .limit(1);
        if (students.isEmpty) throw Exception("Invalid Student Code.");

        // Link Scout to Student
        final studentId = students.first['id'];
        await _supabase.from('scout_students').insert({
          'scout_id': user.id,
          'student_id': studentId,
        });
      }

      // 3. Update the public.users profile
      await _supabase.from('users').update({
        'full_name': fullName,
        'role': finalRole,
        'enrolled_class_id': classIdToEnroll,
        'student_code': generatedStudentCode, // Save generated code if student
      }).eq('id', user.id);

      // 4. Force Sign Out
      await _supabase.auth.signOut();
    } catch (e) {
      await _supabase.auth.signOut();
      throw e;
    }
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// New helper provider to easily access the user's role from anywhere
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

  return response['role'] as String?;
});
