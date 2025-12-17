import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:flutter_tex/flutter_tex.dart';
import 'package:lumalearn/features/session/services/ai_service.dart';

// --- 🛡️ THE SAFETY SHIELD ---
// We define a local model that CANNOT crash.
// It accepts 'dynamic' data and forces it into the right type.
class _SafeMessage {
  final String content;
  final String role;

  _SafeMessage({required this.content, required this.role});

  factory _SafeMessage.fromMap(Map<String, dynamic> data) {
    return _SafeMessage(
      // This helper function eats errors for breakfast
      content: _safeString(data['content']),
      role: _safeString(data['role']) == 'ai' ? 'ai' : 'user',
    );
  }

  // The Magic Function: Converts Ints, Nulls, or anything else to a clean String
  static String _safeString(dynamic value) {
    if (value == null) return "";
    return value.toString(); // Forces "1" from 1, preventing the crash
  }
}

// --- THE SCREEN ---
class SessionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> sessionArgs;
  const SessionScreen({super.key, required this.sessionArgs});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isAiTyping = false;
  late String sessionId;
  late String subject;
  bool _isNewSession = false;

  @override
  void initState() {
    super.initState();
    // 🛡️ Safety Check: Force arguments to be Strings
    subject = widget.sessionArgs['subject']?.toString() ?? 'Session';

    final rawId = widget.sessionArgs['id']?.toString();
    if (rawId != null && rawId.isNotEmpty) {
      sessionId = rawId;
      _isNewSession = false;
    } else {
      sessionId = const Uuid().v4();
      _isNewSession = true;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    _controller.clear();
    final chatService = ref.read(chatServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    try {
      if (_isNewSession) {
        await chatService.createSession(
          id: sessionId,
          subject: subject,
          title: content,
        );
        setState(() => _isNewSession = false);
      }

      // We still use ChatService to SAVE (Sending is easy, reading is hard)
      await chatService.saveMessage(
        sessionId: sessionId,
        content: content,
        role: 'user',
      );

      // Force refresh in case Realtime is disabled
      ref.invalidate(_safeMessageStreamProvider(sessionId));

      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      setState(() => _isAiTyping = true);

      final aiResponse =
          await aiService.getAIResponse(content, sessionId, subject);

      await chatService.saveMessage(
        sessionId: sessionId,
        content: aiResponse,
        role: 'ai',
      );

      // Force refresh again for AI response
      ref.invalidate(_safeMessageStreamProvider(sessionId));

      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ USE THE LOCAL PROVIDER defined below
    final messagesAsync = ref.watch(_safeMessageStreamProvider(sessionId));
    final userRoleAsync = ref.watch(currentUserRoleProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.neonGreen)),
              // If this still errors, it will print the EXACT error text
              error: (err, stack) => Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Debug Error: $err',
                    style: const TextStyle(color: Colors.red)),
              )),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                      child: Text("Start the conversation!",
                          style: TextStyle(color: AppTheme.textGrey)));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _scrollController.offset == 0) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.role == 'user';

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppTheme.neonGreen
                              : AppTheme.surfaceGrey,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isUser
                                ? Radius.zero
                                : const Radius.circular(16),
                            topLeft: !isUser
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                        ),
                        // 🛡️ The content is guaranteed to be a String now
                        child: isUser
                            ? Text(msg.content,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16))
                            : MarkdownBody(
                                data: msg.content,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  code: const TextStyle(
                                      color: AppTheme.neonGreen,
                                      backgroundColor: Colors.black54,
                                      fontFamily: 'monospace'),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                extensionSet: md.ExtensionSet(
                                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                  [
                                    md.EmojiSyntax(),
                                    ...md.ExtensionSet.gitHubFlavored
                                        .inlineSyntaxes
                                  ],
                                ),
                                builders: {
                                  'latex': LatexElementBuilder(),
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (_isAiTyping)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: const Text("Luma is thinking...",
                  style: TextStyle(
                      color: AppTheme.neonGreen, fontStyle: FontStyle.italic)),
            ),

          // INPUT AREA (Teacher Safe)
          userRoleAsync.when(
            data: (role) {
              if (role == 'teacher' || role == 'scout') {
                return SafeArea(
                    top: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: AppTheme.surfaceGrey,
                      child: const Text("Read Only View",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGrey)),
                    ));
              }
              return SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: AppTheme.surfaceGrey,
                        border: Border(top: BorderSide(color: Colors.white10))),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle:
                                  const TextStyle(color: AppTheme.textGrey),
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                        )),
                        const SizedBox(width: 12),
                        GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                    color: AppTheme.neonGreen,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.send,
                                    color: Colors.black, size: 20))),
                      ],
                    ),
                  ));
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// --- 🛡️ THE LOCAL PROVIDER ---
// This lives inside this file and uses our crash-proof _SafeMessage class
final _safeMessageStreamProvider = StreamProvider.family
    .autoDispose<List<_SafeMessage>, String>((ref, sessionId) {
  return Supabase.instance.client
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('session_id', sessionId)
      .order('created_at', ascending: true)
      .map((data) => data.map((map) => _SafeMessage.fromMap(map)).toList());
});

// Helper for User Role
final currentUserRoleProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final data = await Supabase.instance.client
      .from('users')
      .select('role')
      .eq('id', user.id)
      .maybeSingle();
  return data?['role']?.toString();
});

// --- 🧮 MATH RENDERING HELPERS ---

class LatexSyntax extends md.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[\s\S]*?\$\$)|(\$[^$]*\$)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final input = match.input;
    final matchStart = match.start;
    final matchEnd = match.end;
    final text = input.substring(matchStart, matchEnd);
    final isBlock = text.startsWith('\$\$') && text.endsWith('\$\$');
    final content = isBlock
        ? text.substring(2, text.length - 2)
        : text.substring(1, text.length - 1);

    final el = md.Element('latex', [md.Text(content)]);
    el.attributes['style'] = isBlock ? 'block' : 'inline';
    parser.addNode(el);
    return true;
  }
}

class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final content = element.textContent;
    final style = element.attributes['style'];
    final isBlock = style == 'block';

    // Using TeXView for rendering
    return SizedBox(
      key: ValueKey(content), // Force rebuild on content change
      width: double.infinity,
      height: isBlock ? 60 : 40,
      child: TeXView(
        child: TeXViewDocument(r"$$" + content + r"$$",
            style: TeXViewStyle(
              contentColor: const Color(0xFF00FF99), // Neon Green
              fontStyle: TeXViewFontStyle(
                  fontSize: isBlock ? 18 : 16,
                  fontWeight: TeXViewFontWeight.bold),
              backgroundColor: Colors.transparent,
            )),
      ),
    );
  }
}
