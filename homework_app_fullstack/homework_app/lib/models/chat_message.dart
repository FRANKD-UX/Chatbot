class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? homeworkId;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.homeworkId,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      homeworkId: json['homeworkId'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'homeworkId': homeworkId,
      'metadata': metadata,
    };
  }

  factory ChatMessage.user(String content, {String? homeworkId}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      homeworkId: homeworkId,
    );
  }

  factory ChatMessage.bot(String content, {String? homeworkId, Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.bot,
      timestamp: DateTime.now(),
      homeworkId: homeworkId,
      metadata: metadata,
    );
  }

  factory ChatMessage.system(String content, {String? homeworkId}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
      homeworkId: homeworkId,
    );
  }
}

enum MessageType {
  user,
  bot,
  system,
}

