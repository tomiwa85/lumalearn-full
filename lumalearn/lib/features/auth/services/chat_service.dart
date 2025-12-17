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
      // 🛡️ SAFETY FIX: Convert everything to String
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'New Session',
      subject: data['subject']?.toString() ?? 'General',
      // 🛡️ SAFETY FIX: Handle null dates
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String content;
  final String role;
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
      // 🛡️ SAFETY FIX: Convert everything to String
      id: data['id']?.toString() ?? '',
      sessionId: data['session_id']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }
}

// --- SERVICE ---

class ChatService {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  ChatService(this._supabase, this._currentUserId);

  // 1. Create Session
  Future<ChatSession> createSession({
    required String id,
    required String subject,
    required String title,
  }) async {
    if (_currentUserId == null) throw Exception("User not logged in");

    String? classId;
    try {
      final userMap = await _supabase
          .from('users')
          .select('enrolled_class_id')
          .eq('id', _currentUserId!)
          .maybeSingle();

      classId = userMap != null ? userMap['enrolled_class_id']?.toString() : null;
    } catch (e) {
      classId = null;
    }

    try {
      final response = await _supabase.from('chat_sessions').insert({
        'id': id,
        'user_id': _currentUserId,
        'subject': subject,
        'title': title,
        'class_id': classId,
      }).select().single();

      return ChatSession.fromMap(response);
    } catch (e) {
      print("CRITICAL ERROR: Failed to create session. DB Error: $e");
      rethrow;
    }
  }

  // 2. Get History
  Future<List<ChatSession>> getHistory(String subject) async {
    if (_currentUserId == null) return [];

    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', _currentUserId!)
        .eq('subject', subject) // If this is Int in DB, .toString() in Model fixes the crash
        .order('created_at', ascending: false);

    return (response as List).map((e) => ChatSession.fromMap(e)).toList();
  }

  // 3. Get Messages
  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => ChatMessage.fromMap(e)).toList();
  }

  // 4. Save Message
  Future<void> saveMessage({
    required String sessionId,
    required String content,
    required String role,
  }) async {
    if (_currentUserId == null) throw Exception("User not logged in");

    // This requires the 'user_id' column to exist in DB (Step 2 fixes this)
    await _supabase.from('chat_messages').insert({
      'session_id': sessionId,
      'content': content,
      'role': role,
      'user_id': _currentUserId,
    });
  }

  // 5. Get Student Sessions
  Future<List<ChatSession>> getStudentSessions(String studentId) async {
    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', studentId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ChatSession.fromMap(e)).toList();
  }

  // 6. Get Student Sessions By Subject
  Future<List<ChatSession>> getStudentSessionsBySubject(String studentId, String subject) async {
    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', studentId)
        .eq('subject', subject)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ChatSession.fromMap(e)).toList();
  }

  // 7. Get All User Sessions
  Future<List<ChatSession>> getAllUserSessions() async {
    if (_currentUserId == null) return [];
    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', _currentUserId!)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ChatSession.fromMap(e)).toList();
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  return ChatService(Supabase.instance.client, user?.id);
});