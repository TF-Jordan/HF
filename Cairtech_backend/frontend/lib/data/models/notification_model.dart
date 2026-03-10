class NotificationModel {
  final String? id;
  final String? type;
  final String message;
  final String? recipient;
  final String? priority;
  final bool viewed;
  final String? channel;
  final String? createdAt;

  const NotificationModel({
    this.id,
    this.type,
    required this.message,
    this.recipient,
    this.priority,
    this.viewed = false,
    this.channel,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      type: json['type'],
      message: json['message'] ?? '',
      recipient: json['recipient'],
      priority: json['priority'],
      viewed: json['viewed'] ?? false,
      channel: json['channel'],
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'recipient': recipient,
    'priority': priority,
    'channel': channel,
  };
}
