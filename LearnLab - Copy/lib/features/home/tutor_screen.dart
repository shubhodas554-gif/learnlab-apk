import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/openai_service.dart';

class ChatMessage {
  ChatMessage(this.role, this.text);
  final String role; // 'user' | 'assistant'
  final String text;
}

final tutorMessagesProvider = StateNotifierProvider<TutorChatController, List<ChatMessage>>(
  (ref) => TutorChatController(ref.read),
);

class TutorChatController extends StateNotifier<List<ChatMessage>> {
  TutorChatController(this._read) : super(const []);
  final Reader _read;
  final _ai = OpenAiService();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    state = [...state, ChatMessage('user', trimmed)];
    try {
      final reply = await _ai.explain(
        '$trimmed\nProvide a simple, beginner-friendly explanation and an example if possible.',
      );
      state = [...state, ChatMessage('assistant', reply)];
    } catch (e) {
      state = [...state, ChatMessage('assistant', 'Sorry, I had trouble answering: $e')];
    }
  }
}

class TutorScreen extends ConsumerStatefulWidget {
  const TutorScreen({super.key});

  @override
  ConsumerState<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends ConsumerState<TutorScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(tutorMessagesProvider);
    _scrollToBottom();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => _Bubble(message: messages[i]),
            ),
          ),
          _InputBar(
            controller: _controller,
            onSend: () {
              final text = _controller.text;
              _controller.clear();
              ref.read(tutorMessagesProvider.notifier).send(text);
            },
          ),
        ],
      ),
      bottomNavigationBar: const _NavBar(index: 2),
    );
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Ask about any science topic...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'AI Tutor'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Leaderboard'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (i) => _go(context, i),
      );
}

void _go(BuildContext context, int i) {
  switch (i) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/subjects');
      break;
    case 2:
      context.go('/tutor');
      break;
    case 3:
      context.go('/leaderboard');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}
