class User {
  final String name;
  final String email;
  final String userId;
  final List<dynamic> followers;
  final List<dynamic> following;
  String image;

  User({
    required this.name, 
    required this.email, 
    required this.userId,
    required this.followers, 
    required this.following, 
    required this.image
    });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      followers: json['followers'] ?? '',
      following: json['following'] ?? ''
    );
  }
}