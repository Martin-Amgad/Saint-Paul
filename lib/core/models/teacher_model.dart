class TeacherModel {
  final String? uid;
  final String? name;
  final String? church;
  final String? adminPin;

  const TeacherModel({this.uid, this.name, this.church, this.adminPin});

  // Model ← Firestore
  factory TeacherModel.fromJson(Map<String, dynamic> map, String uid) {
    return TeacherModel(
      uid: uid,
      name: map['name'] ?? '',
      church: map['church'] ?? '',
      adminPin: map['adminPin'] ?? '',
    );
  }

  // Model → Firestore
  Map<String, dynamic> toJson() {
    return {'name': name, 'church': church, 'adminPin': adminPin};
  }

  // Model → Firestore (for updates)
  TeacherModel copyWith({String? name, String? church, String? adminPin}) {
    return TeacherModel(
      uid: uid,
      name: name ?? this.name,
      church: church ?? this.church,
      adminPin: adminPin ?? this.adminPin,
    );
  }

  // Model → local (without nulls)
  Map<String, dynamic> toJsonLocal() {
    return {'uid': uid, 'name': name, 'church': church};
  }

  // Firestore → Model
  Map<String, dynamic> toUpdateData() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (church != null) data['church'] = church;
    if (adminPin != null) data['adminPin'] = adminPin;

    return data;
  }
}
