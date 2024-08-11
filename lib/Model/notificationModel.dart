class NotificationModel {
  final String senderId;
  final String uniqueId;
  final String title;
  final String message;
  final String id; // _id field from MongoDB
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.senderId,
    required this.uniqueId,
    required this.title,
    required this.message,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
  return NotificationModel(
    senderId: json['senderId'] ?? '',
    uniqueId: json['noteId'] ?? '',
    title: json['title'] ?? '',
    message: json['message'] ?? '',
    id: json['_id'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

}
