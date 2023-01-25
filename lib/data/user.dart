class User {
  final String name;
  final String email;
  final String token;
  final String id;

  User(
      {required this.name,
      required this.token,
      required this.id,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      token: json['token'],
      id: json['id'],
      email: json['email'],
    );
  }
}
