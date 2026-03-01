class TeacherModel {
  final String? uid;
  final String? adminPin;

  TeacherModel({this.uid, this.adminPin});

  /// Firestore → Model
  factory TeacherModel.fromJson(Map<String, dynamic> map, String uid) {
    return TeacherModel(uid: uid, adminPin: map['password'] ?? '');
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {'password': adminPin};
  }

  /// CopyWith
  TeacherModel copyWith({String? adminPin}) {
    return TeacherModel(uid: uid, adminPin: adminPin ?? this.adminPin);
  }

  /// Partial update for Firestore
  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (adminPin != null) data['adminPin'] = adminPin;
    return data;
  }
}
