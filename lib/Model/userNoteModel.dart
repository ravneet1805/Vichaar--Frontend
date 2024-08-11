import 'package:timeago/timeago.dart' as timeago;

class UserNote {
  final String title;
  final String noteId;
  final DateTime createdAt;
  final List<dynamic> likes;
    final List<dynamic> interested;
  final String userId;
  List<dynamic> comments;
   final String? postImage;
  final List<String>? skills;



  
  UserNote({
    required this.title,
    required this.noteId,
    required this.createdAt,
    required this.likes,
    required this.interested,
    required this.comments,
    required this.userId,
    this.skills,
    this .postImage
    });

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      title: json['title'] ?? '',
      noteId: json['_id'] ?? '',
      userId: json['userId'],
      postImage: json['image'],
      likes: json['likes'],
      interested: json['interested'],
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      comments: json['comments'] ?? '',
      skills: json['skills']

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
