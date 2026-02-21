class TeacherModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? dob;
  final bool darkMode;

  TeacherModel({
    this.uid,
    this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.dob,
    this.darkMode = false,
  });

  /// Firestore → Model
  factory TeacherModel.fromJson(Map<String, dynamic> map, String uid) {
    return TeacherModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      bio: map['bio'] ?? '',
      dob: map['dob'] ?? '',
      darkMode: map['darkMode'] ?? false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'dob': dob,
      'darkMode': darkMode,
    };
  }

  /// CopyWith
  TeacherModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? dob,
    bool? darkMode,
  }) {
    return TeacherModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      dob: dob ?? this.dob,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  /// Partial update for Firestore
  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (bio != null) data['bio'] = bio;
    if (dob != null) data['dob'] = dob;

    data['darkMode'] = darkMode;

    return data;
  }
}
