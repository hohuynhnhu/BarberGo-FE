import 'dart:convert';
import 'package:barbergofe/core/utils/api_config.dart';
import 'package:http/http.dart' as http;


/// Chatbot API Service - Tách biệt logic API
class ChatbotApiService {
  // Endpoints
  static const String _chatEndpoint = "/api/chatbot/chat";
  static const String _healthEndpoint = "/api/chatbot/health";
  static const String _testEndpoint = "/api/chatbot/test";

  // Headers
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Chat with RAG chatbot
  static Future<Map<String, dynamic>> chat({
    required String question,
    int topK = 3,
    bool returnSources = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_chatEndpoint)),
        headers: _headers,
        body: json.encode({
          'question': question,
          'top_k': topK,
          'return_sources': returnSources,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ChatbotException(
          'API Error ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ChatbotException('Network error: ${e.message}');
    } catch (e) {
      throw ChatbotException('Unexpected error: $e');
    }
  }

  /// Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(_healthEndpoint)),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ChatbotException(
          'Health check failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ChatbotException('Network error: ${e.message}');
    } catch (e) {
      throw ChatbotException('Health check error: $e');
    }
  }

  /// Test with sample questions
  static Future<List<Map<String, dynamic>>> testChatbot() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(_testEndpoint)),
        headers: _headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw ChatbotException(
          'Test failed: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ChatbotException('Network error: ${e.message}');
    } catch (e) {
      throw ChatbotException('Test error: $e');
    }
  }
}

/// Custom exception for chatbot errors
class ChatbotException implements Exception {
  final String message;
  final int? statusCode;

  ChatbotException(this.message, {this.statusCode});

  @override
  String toString() => 'ChatbotException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}