import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../services/karigor_ai_service.dart';
import '../../services/karigor_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/request_job_modal.dart';
import 'karigor_direct_chat_screen.dart';

class KarigorAiChatScreen extends StatefulWidget {
  const KarigorAiChatScreen({super.key});

  @override
  State<KarigorAiChatScreen> createState() => _KarigorAiChatScreenState();
}

class _KarigorAiChatScreenState extends State<KarigorAiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<AiChatBubble> _messages = [];
  bool _isThinking = false;
  String _thinkingText = '';

  final List<String> _presetChips = [
    'আমার বাসায় গ্যাস লাইনে সমস্যা',
    'লাইট জ্বলছে না, ইলেকট্রিশিয়ান দরকার',
    'কল দিয়ে পানি পড়ছে',
    'ফ্রিজ ঠান্ডা হচ্ছে না',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatBubble(
        text: 'আসসালামু আলাইকুম! আমি আপনার কারিগর খোঁজ AI সহকারী। বাংলা, English অথবা Banglish — যেভাবে সহজ লাগে লিখুন, আমি বুঝে নেব। কী সমস্যা হচ্ছে বলুন তো?',
        isUser: false,
      ),
    );
  }

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
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(AiChatBubble(text: text, isUser: true));
      _isThinking = true;
      _thinkingText = 'বিশ্লেষণ করা হচ্ছে...';
    });
    _scrollToBottom();

    final ack = KarigorAiService.pick(KarigorAiService.ackPhrases);
    final searching = KarigorAiService.pick(KarigorAiService.searchPhrases);

    // Stage 1: Thinking / Ack
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _thinkingText = '$ack। $searching';
      });
      _scrollToBottom();

      // Stage 2: Intent Detection, matching, tips
      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        final intent = KarigorAiService.detectIntent(text);
        final budget = KarigorAiService.extractBudget(text);

        setState(() {
          _isThinking = false;
        });

        if (intent == null) {
          setState(() {
            _messages.add(
              AiChatBubble(
                text: 'দুঃখিত, ঠিক ধরতে পারলাম না আপনার কোন ধরনের কারিগর দরকার। একটু বিস্তারিত বলবেন কি? যেমন — "প্লাম্বার লাগবে", "electrician দরকার", অথবা "gas line e problem hocche" এভাবে লিখতে পারেন, আমি বাংলা/English/Banglish সবই বুঝি।',
                isUser: false,
              ),
            );
          });
          _scrollToBottom();
          return;
        }

        final repo = KarigorRepository();
        final matches = repo.allProviders
            .where((k) {
              final cat = k.category.toLowerCase();
              if (intent.cat == 'gas') return cat.contains('গ্যাস');
              if (intent.cat == 'electric') return cat.contains('ইলেকট্রিক');
              if (intent.cat == 'plumb') return cat.contains('প্লাম্ব');
              if (intent.cat == 'wood') return cat.contains('কাঠ') || cat.contains('ছুতার');
              if (intent.cat == 'ac') return cat.contains('ac') || cat.contains('এসি');
              if (intent.cat == 'paint') return cat.contains('রং');
              return true;
            })
            .where((k) => k.isOnline)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

        final onlineMatches = matches.take(3).toList();
        final tips = KarigorAiService.categoryTips[intent.cat];
        final tip = (tips != null && tips.isNotEmpty) ? KarigorAiService.pick(tips) : null;

        if (onlineMatches.isEmpty) {
          setState(() {
            _messages.add(
              AiChatBubble(
                text: 'দুঃখিত, এই মুহূর্তে আপনার এলাকায় কোনো ${intent.label} কারিগর অনলাইনে নেই। একটা কাজের অনুরোধ পোস্ট করে রাখুন — কেউ অনলাইনে এলেই জানিয়ে দেব।',
                isUser: false,
                thinkTag: '${intent.icon} ${intent.label} সমস্যা শনাক্ত হয়েছে',
                tip: tip != null ? '💡 এর মধ্যে করণীয়: $tip' : null,
              ),
            );
          });
          _scrollToBottom();
          return;
        }

        final budgetNote = budget != null ? ' আপনার বাজেট ৳$budget-এর কথা মাথায় রেখে' : '';
        final intro = 'আপনার এলাকায়$budgetNote ${onlineMatches.length} জন ${intent.label} কারিগর এখন অনলাইনে পেলাম:';

        setState(() {
          _messages.add(
            AiChatBubble(
              text: intro,
              isUser: false,
              thinkTag: '${intent.icon} ${intent.label} সমস্যা শনাক্ত হয়েছে',
              matchedProviders: onlineMatches,
              tip: tip != null ? '💡 এর মধ্যে একটা পরামর্শ: $tip' : 'উপরের যেকোনো একজনকে সরাসরি অনুরোধ পাঠাতে পারেন, অথবা বিস্তারিত বললে সেই অনুযায়ী ব্যবস্থা নেব।',
            ),
          );
        });
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clayBg,
      body: SafeArea(
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2A4740), Color(0xFF1F3832)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('✨', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'কারিগর খোঁজ AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo Da 2',
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6FCF97),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'সবসময় সক্রিয়',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages Body
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isThinking) {
                    return _buildThinkingBubble();
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Suggestion Chips Row
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _presetChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return ActionChip(
                    label: Text(_presetChips[i]),
                    backgroundColor: AppColors.panel,
                    side: const BorderSide(color: AppColors.line),
                    labelStyle: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () => _sendMessage(_presetChips[i]),
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
                        hintText: 'আপনার সমস্যা লিখুন...',
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _sendMessage(),
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
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.centerLeft,
      child: Container(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.slate),
            ),
            const SizedBox(width: 8),
            Text(
              _thinkingText.isEmpty ? 'বিশ্লেষণ করা হচ্ছে...' : _thinkingText,
              style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiChatBubble msg) {
    if (msg.isUser) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
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
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.thinkTag != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  msg.thinkTag!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              msg.text,
              style: const TextStyle(color: AppColors.ink, fontSize: 13.5, height: 1.45),
            ),
            if (msg.matchedProviders != null && msg.matchedProviders!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...msg.matchedProviders!.map((p) => _buildEmbeddedProviderCard(p)),
            ],
            if (msg.tip != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.clayBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  msg.tip!,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedProviderCard(ProviderModel p) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.brassGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: p.isOnline ? AppColors.success : AppColors.offline,
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
                  p.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${p.category} · ${p.distance.toStringAsFixed(1)} কিমি দূরে',
                  style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
                Text(
                  '⭐ ${p.rating.toStringAsFixed(1)} (${p.reviewCount} রিভিউ)',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.slate, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.slate),
                tooltip: 'চ্যাট করুন',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KarigorDirectChatScreen(karigor: p),
                    ),
                  );
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(60, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: AppColors.terracotta,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  RequestJobModal.show(context, karigor: p);
                },
                child: const Text('অনুরোধ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
