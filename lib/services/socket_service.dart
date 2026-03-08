import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/listing.dart';
import '../models/property.dart';
import '../models/chat.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal() {
    _initSocket();
  }

  late IO.Socket socket;

  final List<Function(Listing)> _listingListeners = [];
  final List<Function(Property)> _propertyListeners = [];
  final List<Function(ChatMessage)> _messageListeners = [];

  void addListingListener(Function(Listing) listener) =>
      _listingListeners.add(listener);
  void addPropertyListener(Function(Property) listener) =>
      _propertyListeners.add(listener);
  void addMessageListener(Function(ChatMessage) listener) =>
      _messageListeners.add(listener);

  void removeListingListener(Function(Listing) listener) =>
      _listingListeners.remove(listener);
  void removePropertyListener(Function(Property) listener) =>
      _propertyListeners.remove(listener);
  void removeMessageListener(Function(ChatMessage) listener) =>
      _messageListeners.remove(listener);

  void _initSocket() {
    final String url = ApiConfig.socketUrl;

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setExtraHeaders({'origin': url}) // Helping with CORS/403
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Connected to socket server: $url');
    });

    socket.onConnectError((err) {
      debugPrint('Socket Connection Error: $err');
      // If websocket fails, it might try polling automatically
    });

    socket.onError((err) => debugPrint('Socket Error: $err'));

    socket.on('new_listing', (data) {
      if (data != null) {
        try {
          final listing = Listing.fromJson(Map<String, dynamic>.from(data));
          for (var listener in _listingListeners) {
            listener(listing);
          }
        } catch (e) {
          debugPrint('Error parsing listing from socket: $e');
        }
      }
    });

    socket.on('new_property', (data) {
      if (data != null) {
        try {
          final property = Property.fromJson(Map<String, dynamic>.from(data));
          for (var listener in _propertyListeners) {
            listener(property);
          }
        } catch (e) {
          debugPrint('Error parsing property from socket: $e');
        }
      }
    });

    socket.on('new_message', (data) {
      if (data != null) {
        try {
          final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
          for (var listener in _messageListeners) {
            listener(msg);
          }
        } catch (e) {
          debugPrint('Error parsing message from socket: $e');
        }
      }
    });

    socket.onDisconnect((_) => debugPrint('Disconnected from socket server'));
    socket.onConnectError((err) => debugPrint('Socket Connection Error: $err'));
  }

  void joinConversation(String conversationId) {
    socket.emit('join_room', {'room': conversationId});
  }

  void leaveConversation(String conversationId) {
    socket.emit('leave_room', {'room': conversationId});
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
