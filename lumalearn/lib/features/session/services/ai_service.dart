import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIService {
  // 🔴 IMPORTANT: Replace this URL with your ACTUAL Render URL
  // It usually looks like: https://your-app-name.onrender.com/chat
  // static const String _serverUrl = "https://luma-ai.onrender.com/chat";

  // 🔧 FORCE LOCAL for testing (change back later)
  // Use localhost for Windows development
  static const String _serverUrl = "http://127.0.0.1:8000/chat";

  // Production URL (uncomment when deploying):
  // static const String _serverUrl = "https://lumalearn-full.onrender.com/chat";

  // Function to send message to Render and get Llama 3's reply
  Future<String> getAIResponse(
      String userMessage, String sessionId, String subject) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "session_id": sessionId,
          "message": userMessage,
          "subject": subject,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']; // The text from Llama 3
      } else {
        return "I am having trouble connecting to the brain (Error ${response.statusCode}).";
      }
    } catch (e) {
      // This happens if your phone has no internet or the server is down
      return "Network Error: $e";
    }
  }
}

// Provider to allow other files to use this service
final aiServiceProvider = Provider((ref) => AIService());
