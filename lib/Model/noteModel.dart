import 'package:timeago/timeago.dart' as timeago;

import 'commentModel.dart';

class Note {
  final String title;
  final String name;
  final String userName;
  final DateTime createdAt;
  final String noteId;
  final List<dynamic> likes;
  final String userId;
  List<dynamic> comments;
  List<dynamic> interested;
  final String image;
   final String? postImage;
  final List<dynamic>? skills;

  Note({
    required this.title,
    required this.name,
    required this.createdAt,
    required this.noteId,
    required this.likes,
    required this.userName,
    required this.comments,
    required this.interested,
    required this.userId,
    required this.image,
    this.skills,
    this .postImage
  });

  factory Note.fromJson(Map<String, dynamic> json) {

    return Note(
      name: json['userId']['fullName'] ?? 'vichaarUser',
      userName: json['userId']['userName'] ?? '',
      image: json['userId']['image'] ?? '',
      userId: json['userId']['_id'],
      title: json['title'] ?? '',
      postImage: json['image'],
      noteId: json['_id'] ?? '',
      likes: json['likes'],
      interested: json['interested'],
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      comments: json['comments'] ?? '',
      skills: json['requiredSkills'] 
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
