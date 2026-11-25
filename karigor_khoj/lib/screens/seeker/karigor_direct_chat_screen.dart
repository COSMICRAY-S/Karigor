import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../services/karigor_repository.dart';
import '../../theme/app_theme.dart';

class KarigorDirectChatScreen extends StatefulWidget {
  final ProviderModel karigor;

  const KarigorDirectChatScreen({super.key, required this.karigor});

  @override
  State<KarigorDirectChatScreen> createState() => _KarigorDirectChatScreenState();
}

class _KarigorDirectChatScreenState extends State<KarigorDirectChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickChips = [
    'আপনি কখন আসতে পারবেন?',
    'খরচ কেমন হবে?',
    'ঠিকানা পাঠাচ্ছি',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? preset]) {
    final text = preset ?? _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    final repo = KarigorRepository();
    repo.sendDirectMessage(widget.karigor.id, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final repo = KarigorRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final messages = repo.getChatHistory(widget.karigor.id, widget.karigor.name);

        return Scaffold(
          backgroundColor: AppColors.clayBg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF2A4740),
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppColors.brassGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.karigor.initial,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: widget.karigor.isOnline ? AppColors.success : AppColors.offline,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.karigor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Baloo Da 2',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.karigor.isOnline ? '🟢 অনলাইন আছেন' : '⚪ অফলাইন',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    return _buildBubble(msg);
                  },
                ),
              ),

              // Quick Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _quickChips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return ActionChip(
                      label: Text(_quickChips[i]),
                      backgroundColor: AppColors.panel,
                      side: const BorderSide(color: AppColors.line),
                      labelStyle: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      onPressed: () => _send(_quickChips[i]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Input Bar
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: const BoxDecoration(
                  color: AppColors.panel,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'মেসেজ লিখুন...',
                          filled: true,
                          fillColor: AppColors.clayBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _send(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.terracotta,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBubble(DirectChatMessage msg) {
    if (msg.isUser) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.line),
          boxShadow: AppTheme.softShadow,
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: AppColors.ink, fontSize: 13.5, height: 1.4),
        ),
      ),
    );
  }
}
