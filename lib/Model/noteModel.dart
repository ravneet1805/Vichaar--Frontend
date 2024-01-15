import 'package:timeago/timeago.dart' as timeago;

import 'commentModel.dart';

class Note {
  final String title;
  final String name;
  final DateTime createdAt;
  final String noteId;
  final List<dynamic> likes;
  final String userId;
  List<dynamic> comments;
  final String image;

  Note({
    required this.title,
    required this.name,
    required this.createdAt,
    required this.noteId,
    required this.likes,
    required this.comments,
    required this.userId,
    required this.image
  });

  factory Note.fromJson(Map<String, dynamic> json) {

    return Note(
      name: json['userId']['name'] ?? 'Anonymous',
      image: json['userId']['image'] ?? '',
      userId: json['userId']['_id'],
      title: json['title'] ?? '',
      noteId: json['_id'] ?? '',
      likes: json['likes'],
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      comments: json['comments'] ?? '',
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return timeago.format(now.subtract(difference));
  }
}
