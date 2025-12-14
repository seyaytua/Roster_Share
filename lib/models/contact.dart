// 参加者マスターリスト用の連絡先モデル
class Contact {
  String id;
  String name;
  String email;
  String? phone;
  String? organization;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.organization,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'organization': organization,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      organization: map['organization'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}
