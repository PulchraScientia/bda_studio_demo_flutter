class ChatMessage {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      isUser: json['isUser'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUser': isUser,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Chat {
  final String id;
  final String assistantId;
  final String experimentId;
  final String name;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.assistantId,
    required this.experimentId,
    required this.name,
    required this.messages,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      assistantId: json['assistantId'],
      experimentId: json['experimentId'],
      name: json['name'],
      messages: (json['messages'] as List).map((e) => ChatMessage.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantId': assistantId,
      'experimentId': experimentId,
      'name': name,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}