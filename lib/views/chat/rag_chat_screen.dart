import 'package:barbergofe/viewmodels/chat/chatbot_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RagChatScreen extends StatefulWidget {
  const RagChatScreen({Key? key}) : super(key: key);

  @override
  _RagChatScreenState createState() => _RagChatScreenState();
}

class _RagChatScreenState extends State<RagChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatbotViewModel(),
      child: Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildChatList()),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF1D1E33),
      elevation: 4,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                "BG",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BarberGo Assistant",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Consumer<ChatbotViewModel>(
                builder: (context, viewModel, child) {
                  return Text(
                    viewModel.isLoading ? "Đang trả lời..." : "Trực tuyến",
                    style: TextStyle(
                      fontSize: 12,
                      color: viewModel.isLoading ? Colors.amber : Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<ChatbotViewModel>(
          builder: (context, viewModel, child) {
            return IconButton(
              icon: Icon(
                viewModel.showSources ? Icons.source_rounded : Icons.source_outlined,
                color: viewModel.showSources ? Colors.blue : Colors.white70,
              ),
              onPressed: () {
                viewModel.toggleShowSources();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.showSources
                          ? "📚 Hiển thị nguồn tham khảo"
                          : "📖 Ẩn nguồn tham khảo",
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: "Hiển thị nguồn tham khảo",
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          color: Color(0xFF1D1E33),
          onSelected: (value) async {
            final viewModel = context.read<ChatbotViewModel>();

            switch (value) {
              case 'clear':
                viewModel.clearChat();
                break;
              case 'health':
                await viewModel.checkHealth();
                break;
              case 'test':
                await viewModel.sendTestQuestions();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text("Xóa cuộc trò chuyện", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'health',
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text("Kiểm tra hệ thống", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'test',
              child: Row(
                children: [
                  Icon(Icons.question_answer, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text("Câu hỏi mẫu", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatbotViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        if (viewModel.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white30),
                SizedBox(height: 20),
                Text(
                  "Chào bạn! Tôi là BarberGo Assistant",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Hỏi tôi bất cứ điều gì về ứng dụng",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: viewModel.messages.length,
          itemBuilder: (context, index) {
            final message = viewModel.messages[index];
            return _buildMessageBubble(message, viewModel.showSources);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showSources) {
    final isUser = message.isUser;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  "BG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (!isUser) SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? Color(0xFF0066CC) : Color(0xFF1D1E33),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                      bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (!isUser && message.confidence != null) ...[
                        SizedBox(height: 8),
                        _buildConfidenceIndicator(message.confidence!),
                      ],
                    ],
                  ),
                ),

                // Sources section
                if (!isUser && showSources && message.sources != null && message.sources!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildSourcesSection(message.sources!),
                ],

                // Timestamp
                Padding(
                  padding: EdgeInsets.only(top: 4, right: isUser ? 8 : 0, left: isUser ? 0 : 8),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: 8),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0066CC),
              ),
              child: Center(
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(String confidence) {
    Color color;
    String text;

    switch (confidence.toLowerCase()) {
      case 'high':
        color = Colors.green;
        text = 'Độ tin cậy cao';
        break;
      case 'medium':
        color = Colors.amber;
        text = 'Độ tin cậy trung bình';
        break;
      case 'low':
        color = Colors.red;
        text = 'Độ tin cậy thấp';
        break;
      default:
        color = Colors.grey;
        text = confidence;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection(List<Source> sources) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source, size: 16, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                "Nguồn tham khảo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...sources.map((source) => _buildSourceItem(source)).toList(),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "❓ ${source.question}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getSimilarityColor(source.similarity),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${(source.similarity * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "💡 ${source.answer}",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 0.8) return Colors.green;
    if (similarity >= 0.6) return Colors.amber;
    return Colors.red;
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildInputField() {
    return Consumer<ChatbotViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF1D1E33),
            border: Border(top: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nhập câu hỏi về BarberGo...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          onSubmitted: (_) => _sendMessage(viewModel),
                        ),
                      ),
                      if (viewModel.isLoading)
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    viewModel.isLoading ? Icons.hourglass_top : Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: viewModel.isLoading ? null : () => _sendMessage(viewModel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(ChatbotViewModel viewModel) {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !viewModel.isLoading) {
      viewModel.sendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }
}