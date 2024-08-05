class User {
  final String name;
  final String userName;
  final String bio;
  final String githubLink;
  final String linkedinLink;
  final List<String>? skills;
  final String email;
  final String userId;
  final List<dynamic> followers;
  final List<dynamic> following;
  String image;

  User({
    required this.name,
    required this.userName,
              this.bio = '',
              this.githubLink = '',
              this.linkedinLink = '',
              this.skills,
    required this.email,
    required this.userId,
    required this.followers,
    required this.following,
    required this.image
    });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'] ?? '',
      name: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      bio: json['bio'] ?? '',
      githubLink: json['githubLink'] ?? '',
      linkedinLink: json['linkedinLink'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      followers: json['followers'] ?? '',
      following: json['following'] ?? ''
    );
  }
}