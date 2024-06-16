class Comment {
  String name;
  String text;
  String id;
  DateTime createdAt;

  Comment({
    required this.name,
    required this.text,
    required this.id,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      name: json['user']['name'] ?? 'Anonymous',
      text: json['text'],
      id: json['_id'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}