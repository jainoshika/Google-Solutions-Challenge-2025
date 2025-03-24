import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chatbot',
      theme: ThemeData(
        primaryColor: Color(0xFF009688),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF009688),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF009688),
          background: Colors.white,
          surface: Color(0xFFE0F2F1),
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GOOGLE_API_KEY'] ?? '',
    );
  }

  void _sendMessage() async {
    final String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final content = [Content.text(messageText)];
      final response = await _model.generateContent(content);

      setState(() {
        _messages.add(
          ChatMessage(text: response.text ?? 'No response', isUser: false),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: 'Error: ${e.toString()}', isUser: false),
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chatbot'),
        backgroundColor: Color(0xFF009688),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009688)),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? Color(0xFF009688).withOpacity(0.2)
                  : Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            message.isUser
                ? Text(message.text, style: TextStyle(color: Color(0xFF009688)))
                : MarkdownBody(
                  data: message.text, // Render AI response with Markdown
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Color(0xFFE0F2F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Color(0xFF009688), width: 2),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Color(0xFF009688),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
