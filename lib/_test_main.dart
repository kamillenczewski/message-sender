import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPaginationScreen(),
    );
  }
}

class Message {
  final String text;
  final DateTime timestamp;

  Message({required this.text, required this.timestamp});
}

class ChatPaginationScreen extends StatefulWidget {
  const ChatPaginationScreen({super.key});

  @override
  State<ChatPaginationScreen> createState() => _ChatPaginationScreenState();
}

class _ChatPaginationScreenState extends State<ChatPaginationScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;

  final List<Message> _mockDatabase = List.generate(
    100,
    (index) => Message(
      text: 'Message item #${100 - index}',
      timestamp: DateTime.now().subtract(Duration(minutes: 100 - index)),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadMoreMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      setState(() => _hasMore = hasMore());

      if (!_isLoading && _hasMore) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    setState(() => _isLoading = true);

    // Simulate database network delay
    await Future.delayed(const Duration(milliseconds: 600));

    DateTime? cursor = _mockDatabase.isNotEmpty && _messages.isNotEmpty
      ? _messages.last.timestamp
      : null;

    // Simulate cursor-based query (WHERE timestamp < cursor ORDER BY timestamp DESC LIMIT 15)
    List<Message> nextBatch;
    if (cursor == null) {
      nextBatch = _mockDatabase.reversed.take(15).toList();
    } else {
      nextBatch = _mockDatabase.reversed
        .where((m) => m.timestamp.isBefore(cursor))
        .take(15)
        .toList();
    }

    setState(() {
      _isLoading = false;

      if (nextBatch.isNotEmpty) {
        _messages.addAll(nextBatch);
      }
    });
  }

  bool hasMore() {
    return _messages.length < _mockDatabase.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Pagination Example')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _hasMore
                    ? 
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      )
                    )
                    :
                    SizedBox.shrink();
                }

                final message = _messages[index];
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _messages.insert(0, Message(text: "XDD", timestamp: DateTime.now()));
                _mockDatabase.add(Message(text: "XDD", timestamp: DateTime.now()));
              });
            },
            child: Text("Add new message"),
          ),
          GestureDetector(
            onTap: () {
              _messages.clear();
              _loadMoreMessages();
            },
            child: Text("Restart"),
          )
        ],
      ),
    );
  }
}