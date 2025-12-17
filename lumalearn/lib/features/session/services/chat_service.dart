import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';

// --- MODELS ---

class ChatSession {
  final String id;
  final String title;
  final String subject;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.createdAt,
  });

  factory ChatSession.fromMap(Map<String, dynamic> data) {
    return ChatSession(
      id: data['id'] ?? '',
      title: data['title'] ?? 'New Session',
      subject: data['subject'] ?? 'General',
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

class ChatMessage {
  final String id; // Added ID for better compatibility
  final String sessionId;
  final String content;
  final String role; // 'user' or 'ai'
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      sessionId: data['session_id'] ?? '',
      content: data['content'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

// --- SERVICE ---

class ChatService {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  ChatService(this._supabase, this._currentUserId);

  // 1. Start a brand new chat (Updated to accept ID)
  Future<ChatSession> createSession({
    required String id, // <--- ADDED THIS PARAMETER
    required String subject,
    required String title,
  }) async {
    if (_currentUserId == null) throw Exception("User not logged in");

    String? classId;

    // TRY to get the Class ID, but if it fails, IGNORE it and continue.
    try {
      final userMap = await _supabase
          .from('users')
          .select('enrolled_class_id')
          .eq('id', _currentUserId!) // Use ! since we checked null above
          .maybeSingle();

      if (userMap != null) {
        classId = userMap['enrolled_class_id'] as String?;
      }
    } catch (e) {
      print(
          "Minor Warning: Could not fetch class ID, proceeding without it. Error: $e");
      classId = null;
    }

    // Insert the session using the ID we passed in
    try {
      final response = await _supabase
          .from('chat_sessions')
          .insert({
            'id': id, // <--- USE THE ID HERE
            'user_id': _currentUserId,
            'subject': subject,
            'title': title,
            'class_id': classId,
          })
          .select()
          .single();

      return ChatSession.fromMap(response);
    } catch (e) {
      print("CRITICAL ERROR: Failed to create session. DB Error: $e");
      rethrow;
    }
  }

  // 2. Get history list for a specific subject (e.g., All "Physics" chats)
  Future<List<ChatSession>> getHistory(String subject) async {
    if (_currentUserId == null) return [];

    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', _currentUserId!)
        .eq('subject', subject)
        .order('created_at', ascending: false); // Newest first

    return (response as List).map((e) => ChatSession.fromMap(e)).toList();
  }

  // 3. Get messages for a specific chat
  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true); // Oldest first

    return (response as List).map((e) => ChatMessage.fromMap(e)).toList();
  }

  // 4. Save a new message bubble
  Future<void> saveMessage({
    required String sessionId,
    required String content,
    required String role,
  }) async {
    if (_currentUserId == null) throw Exception("User not logged in");

    await _supabase.from('chat_messages').insert({
      'session_id': sessionId,
      'content': content,
      'role': role,
      'user_id': _currentUserId, // Ensure the message is linked to the user
    });
  }

  // 5. TEACHER: Get sessions for a specific student (General fetch)
  Future<List<ChatSession>> getStudentSessions(String studentId) async {
    try {
      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('user_id', studentId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => ChatSession.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching student sessions: $e");
      return [];
    }
  }

  // 6. TEACHER: Get sessions for a specific student AND subject
  Future<List<ChatSession>> getStudentSessionsBySubject(
      String studentId, String subject) async {
    try {
      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('user_id', studentId)
          .eq('subject', subject)
          .order('created_at', ascending: false);

      return (response as List).map((e) => ChatSession.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching student history by subject: $e");
      return [];
    }
  }

  // 7. PROFILE: Get ALL sessions for the current user (for Learning History page)
  Future<List<ChatSession>> getAllUserSessions() async {
    if (_currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List).map((e) => ChatSession.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching user history: $e");
      return [];
    }
  }

  // 8. Delete a session (Fix for bug)
  Future<void> deleteSession(String sessionId) async {
    if (_currentUserId == null) throw Exception("User not logged in");

    await _supabase
        .from('chat_sessions')
        .delete()
        .eq('id', sessionId); // RLS will ensure ownership
  }

  // 9. SCOUT: Get list of students linked to this scout
  Future<List<Map<String, dynamic>>> getLinkedStudents() async {
    if (_currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('scout_students')
          .select(
              'student_id, users:student_id(full_name, email)') // Join to get details
          .eq('scout_id', _currentUserId!);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching linked students: $e");
      return [];
    }
  }

  // 10. HELPER: Get latest session for a subject (for persistent chats like Parent/General)
  Future<String?> getLatestSessionId(String subject) async {
    if (_currentUserId == null) return null;
    try {
      final response = await _supabase
          .from('chat_sessions')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('subject', subject)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      print("Reference error fetching latest session: $e");
      return null;
    }
  }
}

// --- PROVIDER ---

final chatServiceProvider = Provider<ChatService>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  return ChatService(Supabase.instance.client, user?.id);
});
