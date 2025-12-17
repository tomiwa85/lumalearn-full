enum MessageType { user, aiHint, aiTopicBreakdown, feedback } // <--- Added feedback

class SessionMessage {
  final String id;
  final String content;
  final MessageType type;
  final bool isLocked;
  final bool isCorrect; // <--- Added to track success/fail

  SessionMessage({
    required this.id,
    required this.content,
    required this.type,
    this.isLocked = false,
    this.isCorrect = false, // Default to false
  });
}