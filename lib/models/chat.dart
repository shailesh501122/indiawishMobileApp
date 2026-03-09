import 'user.dart';

class Conversation {
  final String id;
  final String participantOneId;
  final String participantTwoId;
  final String? listingId;
  final String? propertyId;
  final String? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final UserBasic otherUser;

  Conversation({
    required this.id,
    required this.participantOneId,
    required this.participantTwoId,
    this.listingId,
    this.propertyId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    required this.otherUser,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      participantOneId: json['participant_one_id'] ?? '',
      participantTwoId: json['participant_two_id'] ?? '',
      listingId: json['listing_id'],
      propertyId: json['property_id'],
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      otherUser: UserBasic.fromJson(
        Map<String, dynamic>.from(json['other_user'] ?? {}),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}
