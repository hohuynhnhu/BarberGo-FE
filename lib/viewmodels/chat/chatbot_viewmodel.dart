import 'package:flutter/foundation.dart';
import 'package:barbergofe/services/chatbot_api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? confidence;
  final List<Source>? sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.sources,
  });
}

class Source {
  final String question;
  final String answer;
  final double similarity;

  Source({
    required this.question,
    required this.answer,
    required this.similarity,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      similarity: (json['similarity'] ?? 0).toDouble(),
    );
  }
}

class ChatbotViewModel extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _showSources = false;
  bool _isConnected = true;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showSources => _showSources;
  bool get isConnected => _isConnected;

  ChatbotViewModel() {
    _initializeChat();
  }

  void _initializeChat() {
    // Add welcome message
    _addBotMessage(
      " Xin chào! Tôi là BarberGo Assistant. Tôi có thể giúp bạn:\n\n"
          "• Hướng dẫn đặt/hủy lịch\n"
          "• Thông tin thanh toán, đặt cọc\n"
          "• Tính năng ứng dụng\n"
          "• Hợp tác đối tác\n\n"
          "Hãy hỏi tôi bất cứ điều gì về BarberGo!",
      confidence: "high",
    );
  }

  void toggleShowSources() {
    _showSources = !_showSources;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _addUserMessage(message);

    // Start loading
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call API service
      final result = await ChatbotApiService.chat(
        question: message,
        topK: 3,
        returnSources: _showSources,
      );

      // Update connection status
      _isConnected = true;

      // Parse response
      List<Source>? sources;
      if (_showSources && result['sources'] != null) {
        sources = (result['sources'] as List)
            .map((source) => Source.fromJson(source))
            .toList();
      }

      _addBotMessage(
        result['answer'],
        confidence: result['confidence'],
        sources: sources,
      );
    } on ChatbotException catch (e) {
      _handleApiError(e);
    } catch (e) {
      _handleApiError(ChatbotException('Unexpected error: $e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTestQuestions() async {
    try {
      final results = await ChatbotApiService.testChatbot();

      for (var result in results) {
        _addBotMessage(
          "❓ ${result['question']}\n\n"
              "🤖 ${result['answer']}\n"
              "📊 Độ tin cậy: ${result['confidence']}",
          confidence: result['confidence'],
        );
      }

      _isConnected = true;
    } on ChatbotException catch (e) {
      _handleApiError(e);
    }
  }

  Future<void> checkHealth() async {
    try {
      final healthData = await ChatbotApiService.healthCheck();

      _addBotMessage(
        "✅ Hệ thống hoạt động bình thường\n"
            "📊 Trạng thái: ${healthData['status']}\n"
            "🛠️ Dịch vụ: ${healthData['service']}\n"
            "🧠 Model: ${healthData['model']}",
        confidence: "high",
      );

      _isConnected = true;
    } on ChatbotException catch (e) {
      _addBotMessage(
        "⚠️ Kiểm tra hệ thống thất bại\n"
            "Lỗi: ${e.message}",
        confidence: "low",
      );
      _isConnected = false;
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _addBotMessage(
      "💬 Cuộc trò chuyện đã được làm mới. Tôi có thể giúp gì cho bạn?",
      confidence: "high",
    );
    notifyListeners();
  }

  void retryLastMessage() {
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      if (lastMessage.isUser) {
        sendMessage(lastMessage.text);
      }
    }
  }

  void _handleApiError(ChatbotException e) {
    _isConnected = false;

    String errorMessage;
    if (e.statusCode == 500) {
      errorMessage = "❌ Máy chủ đang gặp sự cố. Vui lòng thử lại sau.";
    } else if (e.statusCode == 404) {
      errorMessage = "⚠️ Không tìm thấy endpoint. Vui lòng kiểm tra kết nối API.";
    } else if (e.statusCode == 400) {
      errorMessage = "📝 Câu hỏi không hợp lệ. Vui lòng thử lại với nội dung khác.";
    } else if (e.message.contains('Network')) {
      errorMessage = "🌐 Không thể kết nối đến máy chủ. Kiểm tra internet.";
    } else {
      errorMessage = "⚠️ Đã xảy ra lỗi: ${e.message}";
    }

    _addBotMessage(errorMessage, confidence: "low");
    _error = e.message;
  }

  void _addUserMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _addBotMessage(String text, {String? confidence, List<Source>? sources}) {
    _messages.add(ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      confidence: confidence,
      sources: sources,
    ));
    notifyListeners();
  }
}