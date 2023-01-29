// ignore_for_file: non_constant_identifier_names

class Invite {
  final String? title;
  final String? subtitle;
  final String? groupName;
  final String? groupDescription;
  final String? senderEmail;

  final String id;
  final String group_id;
  final String sender_account_id;
  final String recipient_account_id;

  Invite({
    this.groupName,
    this.groupDescription,
    this.senderEmail,
    this.title,
    this.subtitle,
    required this.id,
    required this.group_id,
    required this.sender_account_id,
    required this.recipient_account_id,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] ?? "",
      group_id: json['group_id'] ?? "",
      sender_account_id: json['sender_account_id'] ?? "",
      recipient_account_id: json['recipient_account_id'] ?? "",
    );
  }
}
