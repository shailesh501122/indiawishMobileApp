import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  List<Conversation> _conversations = [];
  Map<String, List<ChatMessage>> _messages = {};
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socketService.addMessageListener((msg) {
      handleNewMessage(msg);
    });
    _socketService.socket.on('messages_read', (data) {
      if (data != null) {
        handleMessagesRead(data['conversation_id']);
      }
    });
  }

  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversations = await _apiService.getConversations();
      // Only update if we actually got a response (even if empty list)
      // If error occurs, getConversations returns [] currently, but let's make it smarter
      _conversations = conversations;
    } catch (e) {
      debugPrint('Error in ChatProvider.fetchConversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ChatMessage> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> fetchMessages(String conversationId) async {
    try {
      final msgs = await _apiService.getMessages(conversationId);
      if (msgs.isNotEmpty || !_messages.containsKey(conversationId)) {
        _messages[conversationId] = msgs;
        notifyListeners();
      }
      _socketService.joinConversation(conversationId);
      // Mark as read when entering chat
      markAsRead(conversationId);
    } catch (e) {
      debugPrint('Error in ChatProvider.fetchMessages: $e');
    }
  }

  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final msg = await _apiService.sendMessage(conversationId, content);
    if (msg != null) {
      if (_messages[conversationId] == null) {
        _messages[conversationId] = [];
      }
      // Only add if not already present (sometimes socket and POST both return same msg)
      if (!_messages[conversationId]!.any((m) => m.id == msg.id)) {
        _messages[conversationId]!.add(msg);
        notifyListeners();
      }
      fetchConversations();
    }
  }

  void handleNewMessage(ChatMessage msg) {
    if (_messages[msg.conversationId] == null) {
      _messages[msg.conversationId] = [];
    }
    if (!_messages[msg.conversationId]!.any((m) => m.id == msg.id)) {
      _messages[msg.conversationId]!.add(msg);

      // Show notification using conversation hash as ID
      NotificationService().showNotification(
        id: msg.conversationId.hashCode,
        title: 'New Message',
        body: msg.content,
        payload: msg.conversationId,
      );

      notifyListeners();
    }
    fetchConversations();
  }

  Future<Conversation?> startConversation(
    String otherUserId, {
    String? listingId,
    String? propertyId,
    String? initialMessage,
  }) async {
    final conv = await _apiService.startConversation(
      otherUserId,
      listingId: listingId,
      propertyId: propertyId,
      initialMessage: initialMessage,
    );
    if (conv != null) {
      if (!_conversations.any((c) => c.id == conv.id)) {
        _conversations.insert(0, conv);
      }
      notifyListeners();
    }
    return conv;
  }

  Future<void> markAsRead(String conversationId) async {
    final success = await _apiService.markAsRead(conversationId);
    if (success) {
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        // We can't actually change the model field because it's final,
        // but we can refetch or just clear locally if we had a non-final version.
        // For now, let's just trigger a refetch of conversations to get accurate counts.
        fetchConversations();
      }
    }
  }

  Future<void> initiateCall(String otherUserId, String type) async {
    await _apiService.sendCallSignal(otherUserId, type);
  }

  void handleMessagesRead(String conversationId) {
    if (_messages.containsKey(conversationId)) {
      for (var i = 0; i < _messages[conversationId]!.length; i++) {
        final msg = _messages[conversationId]![i];
        if (!msg.isRead) {
          // Update the message read status. Since it's final we recreate.
          _messages[conversationId]![i] = ChatMessage(
            id: msg.id,
            conversationId: msg.conversationId,
            senderId: msg.senderId,
            content: msg.content,
            createdAt: msg.createdAt,
            isRead: true,
          );
        }
      }
      notifyListeners();
    }

    // Update conversation unread count
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      // Mark local count as 0
      fetchConversations(); // Simpler than recreating the model object if final
    }

    // Cancel notification if any
    NotificationService().cancelNotificationsForConversation(conversationId);
  }
}
