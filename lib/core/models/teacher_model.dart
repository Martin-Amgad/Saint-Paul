class TeacherModel {
  final String? uid;
  final String? name;
  final String? church;
  final String? adminPin;
  final String? role;
  final String? assignedFamily;
  final String? assignedStudyLevel;
  final List<String>? assignedStudentIds;

  const TeacherModel({
    this.uid,
    this.name,
    this.church,
    this.adminPin,
    this.role,
    this.assignedFamily,
    this.assignedStudyLevel,
    this.assignedStudentIds,
  });

  // Model ← Firestore
  factory TeacherModel.fromJson(Map<String, dynamic> map, String uid) {
    return TeacherModel(
      uid: uid,
      name: map['name'] ?? '',
      church: map['church'] ?? '',
      role: map['role'] ?? '',
      assignedFamily: map['assignedFamily'] ?? '',
      assignedStudyLevel: map['assignedStudyLevel'] ?? '',
      assignedStudentIds: map['assignedStudentIds'] is List
          ? List<String>.from(map['assignedStudentIds'])
          : const <String>[],
    );
  }

  // Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'church': church,
      'role': role,
      'assignedFamily': assignedFamily,
      'assignedStudyLevel': assignedStudyLevel,
      'assignedStudentIds': assignedStudentIds ?? [],
    };
  }

  // Model → Firestore (for updates)
  TeacherModel copyWith({
    String? name,
    String? church,
    String? role,
    String? assignedFamily,
    String? assignedStudyLevel,
    List<String>? assignedStudentIds,
  }) {
    return TeacherModel(
      uid: uid,
      name: name ?? this.name,
      church: church ?? this.church,
      role: role ?? this.role,
      assignedFamily: assignedFamily ?? this.assignedFamily,
      assignedStudyLevel: assignedStudyLevel ?? this.assignedStudyLevel,
      assignedStudentIds: assignedStudentIds ?? this.assignedStudentIds,
    );
  }

  // Model → local (without nulls)
  Map<String, dynamic> toJsonLocal() {
    return {
      'uid': uid,
      'name': name,
      'church': church,
      'role': role,
      'assignedFamily': assignedFamily,
      'assignedStudyLevel': assignedStudyLevel,
      'assignedStudentIds': assignedStudentIds ?? [],
    };
  }

  // Firestore → Model
  Map<String, dynamic> toUpdateData() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (church != null) data['church'] = church;
    if (role != null) data['role'] = role;
    if (assignedFamily != null) data['assignedFamily'] = assignedFamily;
    if (assignedStudyLevel != null) {
      data['assignedStudyLevel'] = assignedStudyLevel;
    }
    if (assignedStudentIds != null) {
      data['assignedStudentIds'] = assignedStudentIds;
    }

    return data;
  }
}
