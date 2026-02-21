class StudentModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final int? totalTayo;
  final Map<String, dynamic>? tayo;
  final String? dob;
  final bool darkMode;

  StudentModel({
    this.uid,
    this.name,
    this.email,
    this.avatarUrl,
    this.totalTayo = 0,
    this.dob,
    this.darkMode = false,
    this.tayo = const {
      'حضور القداس': 0,
      'حضور القداس قبل المستر': 0,
      'هدوء و مفتحش الموبيل في القداس': 0,
      'دخل الاجتماع من 11:30 ل 11:40 صباحا': 0,
      'سلوك كويس في الاجتماع': 0,
      'مفتحش الموبيل و الفقرة شغالة': 0,
      'اجابة علي سؤال في الدرس': 0,
    },
  });

  /// Firestore → Model
  factory StudentModel.fromJson(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,
      dob: map['dob'] ?? '',
      tayo: map['tayo'] as Map<String, dynamic>? ?? {},
      darkMode: map['darkMode'] ?? false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'totalTayo': totalTayo,
      'dob': dob,
      'darkMode': darkMode,
      'tayo': tayo,
    };
  }

  /// CopyWith
  StudentModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? totalTayo,
    String? dob,
    bool? darkMode,
    Map<String, dynamic>? tayo,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalTayo: totalTayo ?? this.totalTayo,
      dob: dob ?? this.dob,
      darkMode: darkMode ?? this.darkMode,
      tayo: tayo ?? this.tayo,
    );
  }

  /// Partial update for Firestore
  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (totalTayo != null) data['totalTayo'] = totalTayo;
    if (dob != null) data['dob'] = dob;
    if (tayo != null) data['tayo'] = tayo;
    data['darkMode'] = darkMode;

    return data;
  }
}
