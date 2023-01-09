class User {
  final String username;
  final String email;
  final String token;
  final String id;

  User(
      {required this.username,
      required this.token,
      required this.id,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      token: json['token'],
      id: json['id'],
      email: json['email'],
    );
  }
}
