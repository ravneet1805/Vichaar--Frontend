class UserNote {
  final String title;
  final String noteId;
  
  UserNote({required this.title, required this.noteId});

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      title: json['title'] ?? '',
      noteId: json['_id'] ?? ''
    );
  }
}
