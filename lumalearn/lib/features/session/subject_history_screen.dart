import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';

// --- DATA MODEL (Mini version for the list) ---
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;

  ChatSession({required this.id, required this.title, required this.createdAt});

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Session',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// --- REAL-TIME PROVIDER ---
// This listens to the database. If you create a new chat, this updates INSTANTLY.
final sessionHistoryProvider = StreamProvider.family
    .autoDispose<List<ChatSession>, String>((ref, subjectName) {
  final userId = Supabase.instance.client.auth.currentUser!.id;

  return Supabase.instance.client
      .from('chat_sessions')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId) // Only my chats
      // Only for this subject (e.g., Math)
      .order('created_at', ascending: false) // Newest first
      .map((data) {
        // 2. App filters by SUBJECT (Manual fix)
        final relevantChats =
            data.where((map) => map['subject'] == subjectName);

        return relevantChats.map((map) => ChatSession.fromMap(map)).toList();
      });
});

// --- SCREEN WIDGET ---
class SubjectHistoryScreen extends ConsumerWidget {
  final String subjectName;

  const SubjectHistoryScreen({
    super.key,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time stream
    final historyAsync = ref.watch(sessionHistoryProvider(subjectName));

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text(subjectName),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: historyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (sessions) {
          // EMPTY STATE
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppTheme.textGrey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No $subjectName sessions yet.",
                    style:
                        const TextStyle(color: AppTheme.textGrey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  _StartNewButton(subjectName: subjectName),
                ],
              ),
            );
          }

          // LIST OF CHATS
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return Dismissible(
                      key: Key(session.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        // Optimistic UI update is handled by stream, but we delete from DB
                        try {
                          await ref
                              .read(chatServiceProvider)
                              .deleteSession(session.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Session deleted")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error deleting: $e")),
                            );
                          }
                        }
                      },
                      child: Card(
                        color: AppTheme.surfaceGrey,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            session.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, h:mm a')
                                .format(session.createdAt),
                            style: const TextStyle(
                                color: AppTheme.textGrey, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: AppTheme.neonGreen, size: 16),
                          onTap: () async {
                            // Open EXISTING Chat
                            await context.push('/session', extra: {
                              'id': session.id,
                              'subject': subjectName,
                            });
                            // Refresh history when coming back (SAFELY)
                            if (context.mounted) {
                              ref.refresh(sessionHistoryProvider(subjectName));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // "Start New" Button at the bottom
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _StartNewButton(subjectName: subjectName),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StartNewButton extends ConsumerWidget {
  final String subjectName;
  const _StartNewButton({required this.subjectName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Start New Session",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () async {
          // Start NEW Chat (Pass null ID)
          await context.push('/session', extra: {
            'id': null,
            'subject': subjectName,
          });
          // Refresh history when coming back (SAFELY)
          if (context.mounted) {
            ref.refresh(sessionHistoryProvider(subjectName));
          }
        },
      ),
    );
  }
}
