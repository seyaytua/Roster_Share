enum AttendanceStatus {
  attending,
  declined,
  pending,
}

class Participant {
  String id;
  String name;
  String email;
  AttendanceStatus status;
  String? notes;
  DateTime? respondedAt;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    this.status = AttendanceStatus.pending,
    this.notes,
    this.respondedAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.index,
      'notes': notes,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Map
  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      status: AttendanceStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'] as int)
          : null,
    );
  }
}

class Event {
  String id;
  String title;
  String description;
  DateTime dateTime;
  String location;
  List<Participant> participants;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.participants,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Count attendance statuses
  int get attendingCount =>
      participants.where((p) => p.status == AttendanceStatus.attending).length;

  int get declinedCount =>
      participants.where((p) => p.status == AttendanceStatus.declined).length;

  int get pendingCount =>
      participants.where((p) => p.status == AttendanceStatus.pending).length;

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'location': location,
      'participants': participants.map((p) => p.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      location: map['location'] as String,
      participants: (map['participants'] as List)
          .map((p) => Participant.fromMap(p as Map<String, dynamic>))
          .toList(),
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}
