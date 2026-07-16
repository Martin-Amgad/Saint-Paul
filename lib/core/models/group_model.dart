class GroupModel {
  final String? gid;
  final String? name;
  final int? totalTayo;
  final int? totalPoints;
  final List<String>? students;
  final String? studyLevel;
  final Map<String, dynamic>? points;
  final String? groupChurch;
  final String? groupFamily;

  GroupModel({
    this.gid,
    this.name,
    this.totalTayo,
    this.totalPoints,
    this.students,
    this.studyLevel,
    this.points,
    this.groupChurch,
    this.groupFamily,
  });

  factory GroupModel.fromJson(Map<String, dynamic> map, String mid) {
    return GroupModel(
      gid: mid,
      name: map['name'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      students: map['students'] is List
          ? List<String>.from(map['students'])
          : const <String>[],
      studyLevel: map['studyLevel'] ?? '',
      points: map['points'] as Map<String, dynamic>? ?? {},
      groupChurch: map['groupChurch'] ?? '',
      groupFamily: map['groupFamily'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalTayo': totalTayo,
      'totalPoints': totalPoints,
      'students': students,
      'studyLevel': studyLevel,
      'points': points,
      'groupChurch': groupChurch,
      'groupFamily': groupFamily,
    };
  }

  GroupModel copyWith({
    String? mid,
    String? name,
    int? totalTayo,
    int? totalPoints,
    List<String>? students,
    String? studyLevel,
    Map<String, dynamic>? points,
    String? groupChurch,
    String? groupFamily,
  }) {
    return GroupModel(
      gid: gid,
      name: name ?? this.name,
      totalTayo: totalTayo ?? this.totalTayo,
      totalPoints: totalPoints ?? this.totalPoints,
      students: students ?? this.students,
      studyLevel: studyLevel ?? this.studyLevel,
      points: points ?? this.points,
      groupChurch: groupChurch ?? this.groupChurch,
      groupFamily: groupFamily ?? this.groupFamily,
    );
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (totalTayo != null) data['totalTayo'] = totalTayo;
    if (totalPoints != null) data['totalPoints'] = totalPoints;
    if (students != null) data['students'] = students;
    if (studyLevel != null) data['studyLevel'] = studyLevel;
    if (points != null) data['points'] = points;
    if (groupChurch != null) data['groupChurch'] = groupChurch;
    if (groupFamily != null) data['groupFamily'] = groupFamily;

    return data;
  }
}
