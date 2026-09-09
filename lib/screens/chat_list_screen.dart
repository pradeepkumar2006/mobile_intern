import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Matches', 'Creators', 'Unread'];

  final List<Map<String, dynamic>> _onlineMatches = [
    {
      'name': 'Olivia',
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
      'isOnline': true,
    },
    {
      'name': 'Maya',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'isOnline': true,
    },
    {
      'name': 'Joyce',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
      'isOnline': true,
    },
    {
      'name': 'Ria',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      'isOnline': false,
    },
    {
      'name': 'Liam',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
      'isOnline': true,
    },
  ];

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Olivia Fisher',
      'role': 'Creator',
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
      'lastMessage': 'Hey Alex! Loved your profile vibe ✨',
      'time': '2m ago',
      'unread': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Maya Patel',
      'role': 'Creator',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'lastMessage': 'Thanks for the Diamond gift! You are so sweet 💎',
      'time': '18m ago',
      'unread': 1,
      'isOnline': true,
    },
    {
      'id': '3',
      'name': 'Joyce Lin',
      'role': 'Match',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
      'lastMessage': 'Are you free for coffee tomorrow afternoon?',
      'time': '1h ago',
      'unread': 0,
      'isOnline': true,
    },
    {
      'id': '4',
      'name': 'Ria Sen',
      'role': 'Creator',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      'lastMessage': 'Just wrapped up the runway shoot! 📸',
      'time': '3h ago',
      'unread': 0,
      'isOnline': false,
    },
    {
      'id': '5',
      'name': 'Liam Vance',
      'role': 'Match',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
      'lastMessage': 'Check out this secret sunset spot I found!',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': true,
    },
  ];

  void _openChatRoom(Map<String, dynamic> conv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(conversation: conv),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _conversations.where((c) {
      if (_selectedFilterIndex == 1) return c['role'] == 'Match';
      if (_selectedFilterIndex == 2) return c['role'] == 'Creator';
      if (_selectedFilterIndex == 3) return (c['unread'] as int) > 0;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFD),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pineDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.seafoamTeal.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '3 New',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.pineDark,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 95),
                children: [
                  // Active Matches Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Active Matches',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _onlineMatches.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final m = _onlineMatches[index];
                        return Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(m['avatar']),
                                ),
                                if (m['isOnline'] == true)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981), // Active green
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.pineDark,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilterIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.pineDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.pineDark : AppColors.borderLight,
                              ),
                            ),
                            child: Text(
                              _filters[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Conversations List
                  ...filteredList.map((conv) {
                    final int unread = conv['unread'] as int;
                    return InkWell(
                      onTap: () => _openChatRoom(conv),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(conv['avatar']),
                                ),
                                if (conv['isOnline'] == true)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        conv['name'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                                          color: AppColors.pineDark,
                                        ),
                                      ),
                                      if (conv['role'] == 'Creator') ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified_rounded, color: AppColors.seafoamTeal, size: 16),
                                      ],
                                      const Spacer(),
                                      Text(
                                        conv['time'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: unread > 0 ? AppColors.seafoamTeal : AppColors.textMuted,
                                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv['lastMessage'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                                            color: unread > 0 ? AppColors.pineDark : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      if (unread > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: const BoxDecoration(
                                            color: AppColors.seafoamTeal,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unread.toString(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
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
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const _ChatRoomView({required this.conversation});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hey Alex! Loved your profile vibe ✨',
      'time': '10:30 AM',
    },
    {
      'isMe': true,
      'text': 'Hey Olivia! Really love your fashion designs. Let\'s grab coffee sometime!',
      'time': '10:32 AM',
    },
    {
      'isMe': false,
      'text': 'I would love that! How about this weekend?',
      'time': '10:33 AM',
    },
  ];

  void _sendMessage() {
    final txt = _msgController.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'text': txt,
        'time': 'Just now',
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.pineDark, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(conv['avatar']),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv['name'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pineDark,
                  ),
                ),
                Text(
                  'Online now',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded, color: AppColors.seafoamTeal),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gift sent to ${conv['name']} from your Wallet!'),
                  backgroundColor: AppColors.seafoamTeal,
                ),
              );
            },
            tooltip: 'Send Gift',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.pineDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = (m['isMe'] as bool?) ?? false;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.pineDark : Colors.white,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(18),
                        bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(18),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['text'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isMe ? Colors.white : AppColors.pineDark,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m['time'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: isMe ? AppColors.softMint : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.seafoamTeal),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
