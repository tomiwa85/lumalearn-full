import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_message.dart';

// 1. The State Class
class SessionState {
  final bool isLoading;
  final List<SessionMessage> messages;

  SessionState({this.isLoading = false, this.messages = const []});

  SessionState copyWith({bool? isLoading, List<SessionMessage>? messages}) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
    );
  }
}

// 2. The Logic (Notifier)
class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState(messages: _initialDemoData));

  void submitUserAnswer(String text) async {
    if (text.trim().isEmpty) return;

    // A. Add User Message
    final userMsg = SessionMessage(
      id: DateTime.now().toString(),
      content: text,
      type: MessageType.user,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true, // Start loading
    );

    // B. Simulate AI Thinking
    await Future.delayed(const Duration(milliseconds: 1500));

    // C. Check Answer (Mock Logic)
    // Rule: If the user types "50", it is Correct.
    final bool isCorrect = text.contains("50N");

    final SessionMessage aiResponse;

    if (isCorrect) {
      aiResponse = SessionMessage(
        id: DateTime.now().toString() + "_ai",
        content: "Correct! Great job. The force is indeed 50N.",
        type: MessageType.feedback,
        isCorrect: true,
      );
    } else {
      aiResponse = SessionMessage(
        id: DateTime.now().toString() + "_ai",
        content: "Not quite. Check your answer and your units. Remember F = m * a.",
        type: MessageType.feedback,
        isCorrect: false,
      );
    }

    // D. Add AI Response & Stop Loading
    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isLoading: false,
    );
  }
}

// 3. The Provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

// --- Demo Data ---
final _initialDemoData = [
  SessionMessage(
    id: '1',
    type: MessageType.aiTopicBreakdown,
    content: "Newton's Second Law: F = ma ,if mass is 10kg and acceleration is 5m/s^2",
  ),
  SessionMessage(
    id: '2',
    type: MessageType.aiHint,
    content: "Think about the relationship between Force and Mass.",
    isLocked: false,
  ),
  SessionMessage(
    id: '3',
    type: MessageType.aiHint,
    content: "The formula is F = m * a.",
    isLocked: true,
  ),
];