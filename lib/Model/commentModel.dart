import 'package:timeago/timeago.dart' as timeago;

class Comment {
  String name;
  String userName;
  String text;
  String commentId;
  String userId;
  String image;
  DateTime createdAt;

  Comment({
    required this.name,
    required this.userName,
    required this.text,
    required this.commentId,
      this.userId = "",
      this.image = "",
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'],
      commentId: json['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      image: json['user']['image'],
      userName: json['user']['userName']?? '',
      userId: json['user']['_id'],
      name: json['user']['name'] ?? 'user',

      
      
    );

    
  }
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return timeago.format(now.subtract(difference));
  }

  String formatTime() {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}min';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 30) {
    return '${difference.inDays}d';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '${months}mo';
  } else {
    int years = (difference.inDays / 365).floor();
    return '${years}y';
  }
  }
}