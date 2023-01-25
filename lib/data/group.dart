// ignore_for_file: non_constant_identifier_names

class NewGroup {
  final String id;
  final String name;
  final String description;
  final String created_at;
  final List<OldGroupMember>? members;

  NewGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.created_at,
    this.members,
  });

  factory NewGroup.fromJson(Map<String, dynamic> json) {
    return NewGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      created_at: json['created_at'].toString(),
    );
  }
}

class OldGroupMember {
  final String account_id;
  final String role;
  final String created_at;
  String? name;
  String? email;

  OldGroupMember(
    this.name,
    this.email, {
    required this.account_id,
    required this.role,
    required this.created_at,
  });

  void setName(String name) {
    this.name = name;
  }

  void setEmail(String email) {
    this.email = email;
  }

  factory OldGroupMember.fromJson(Map<String, dynamic> json) {
    return OldGroupMember(
      "",
      "",
      account_id: json['account_id'],
      role: json['role'],
      created_at: json['created_at'].toString(),
    );
  }
}
