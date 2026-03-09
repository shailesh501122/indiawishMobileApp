import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/chat_provider.dart';
import '../../models/user.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeFilter = 'All';

  final List<String> _quickFilters = [
    'All',
    'Unread',
    'Important',
    'Elite Buyer',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.darkText),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Column(
            children: [
              // Tabs: ALL / BUYING / SELLING
              Container(
                color: AppColors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'ALL'),
                    Tab(text: 'BUYING'),
                    Tab(text: 'SELLING'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Elite buyer banner
          _buildEliteBanner(),
          // Quick filters
          _buildQuickFilters(),
          // Chat list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(),
                _buildEmptyTab('No buying chats yet'),
                _buildEmptyTab('No selling chats yet'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteBanner() {
    return Container(
      color: const Color(0xFFE8EEF6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.primary,
                  size: 18,
                ),
                Text(
                  'ELITE\nBUYER',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serious about buying?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'Unlock Contact of Owners',
                  style: TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
            ),
            child: const Text(
              'Buy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              'QUICK FILTERS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _quickFilters.map((filter) {
                final isSelected = _activeFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        var filteredConversations = provider.conversations;
        if (_activeFilter == 'Unread') {
          filteredConversations = filteredConversations
              .where((c) => c.unreadCount > 0)
              .toList();
        } else if (_activeFilter == 'Elite Buyer') {
          filteredConversations = filteredConversations
              .where((c) => c.otherUser.isElite)
              .toList();
        } else if (_activeFilter == 'Important') {
          // You could add logic here for important flag if available
          // For now, let's just show all
        }

        if (filteredConversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  _activeFilter == 'All'
                      ? 'No messages yet'
                      : 'No $_activeFilter chats found',
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => provider.fetchConversations(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchConversations,
          child: ListView.separated(
            itemCount: filteredConversations.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 72,
              color: AppColors.lightGrey,
            ),
            itemBuilder: (context, index) {
              final conv = filteredConversations[index];
              return _buildChatItem(context, conv);
            },
          ),
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, dynamic conv) {
    final timeStr = _formatTime(conv.updatedAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(conversation: conv),
          ),
        );
      },
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listing thumbnail + avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.grey,
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.lightGrey,
                        backgroundImage: conv.otherUser.profilePicUrl != null
                            ? NetworkImage(conv.otherUser.profilePicUrl!)
                            : null,
                        child: conv.otherUser.profilePicUrl == null
                            ? Text(
                                conv.otherUser.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      if (_isOnline(conv.otherUser))
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.otherUser.fullName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _isOnline(conv.otherUser)
                        ? 'Online'
                        : _formatLastSeen(conv.otherUser.lastSeen),
                    style: TextStyle(
                      fontSize: 10,
                      color: _isOnline(conv.otherUser)
                          ? Colors.green
                          : AppColors.grey,
                      fontWeight: _isOnline(conv.otherUser)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage ?? 'Start a conversation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: conv.unreadCount > 0
                                ? AppColors.darkText
                                : AppColors.grey,
                            fontSize: 12,
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.more_vert, color: AppColors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.grey, fontSize: 14),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 5) {
      return DateFormat('d MMM yyyy').format(dt);
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat.jm().format(dt);
    }
  }

  bool _isOnline(UserBasic user) {
    if (user.lastSeen == null) return false;
    final now = DateTime.now();
    return now.difference(user.lastSeen!).inMinutes < 5;
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 60) {
      return 'Seen ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return 'Seen ${diff.inHours}h ago';
    } else {
      return 'Seen ${DateFormat('MMM d').format(lastSeen)}';
    }
  }
}
