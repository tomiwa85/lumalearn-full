import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTS ---
import '../../shared/widgets/scaffold_with_navbar.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/progress_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/profile/student_management_screen.dart';
import '../../features/profile/student_detail_screen.dart';
import '../../features/profile/scout_dashboard_screen.dart'; // [NEW]
import '../../features/profile/scout_student_history_screen.dart'; // [NEW]
// Updated Session Imports
import '../../features/session/session_screen.dart';
import '../../features/session/subject_history_screen.dart';
import '../../features/profile/teacher_view/student_subjects_screen.dart';
import '../../features/profile/teacher_view/teacher_student_history_screen.dart';
import '../../features/profile/learning_history_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // LISTEN TO AUTH CHANGES
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),

    // THE GUARD LOGIC
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      // Rule: If NOT logged in, and trying to go to protected pages -> Go to Login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }

      // Note: We removed the "Force Home" rule so sign-up works smoothly
      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- 1. SUBJECT HISTORY SCREEN ---
      // This is the new "List of Chats" screen
      GoRoute(
        path: '/subject-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          // Expecting just the name, e.g., "Physics"
          final subject = state.extra as String;
          return SubjectHistoryScreen(subjectName: subject);
        },
      ),

      // --- 2. SESSION SCREEN (ACTUAL CHAT) ---
      GoRoute(
        path: '/session',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          // The data passed is a Map: {'subject': 'Math', 'id': '...'}
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SessionScreen(sessionArgs: args);
        },
      ),
      GoRoute(
        path: '/student-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final studentData = state.extra as Map<String, dynamic>;
          return StudentDetailScreen(studentData: studentData);
        },
      ),
      // --- 3. MANAGE STUDENTS SCREEN ---
      GoRoute(
        path: '/manage-students',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StudentManagementScreen(),
      ),
      GoRoute(
        path: '/student-subjects',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final studentData = state.extra as Map<String, dynamic>;
          return StudentSubjectsScreen(studentData: studentData);
        },
      ),

      // 2. TEACHER: Specific Subject History
      GoRoute(
        path: '/teacher-student-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return TeacherStudentHistoryScreen(
            studentId: params['studentId'],
            studentName: params['studentName'],
            subject: params['subject'],
          );
        },
      ),

      // 3. PROFILE: Learning History
      GoRoute(
        path: '/learning-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LearningHistoryScreen(),
      ),

      // 4. SCOUT DASHBOARD
      GoRoute(
        path: '/scout-dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ScoutDashboardScreen(),
      ),

      // 5. SCOUT HISTORY
      GoRoute(
        path: '/scout-student-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return ScoutStudentHistoryScreen(
            studentId: params['studentId'],
            studentName: params['studentName'],
          );
        },
      ),
    ],
  );
});

// Helper Class for Stream Listening
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
