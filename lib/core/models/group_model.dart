class GroupModel {
  final String? gid;
  final String? name;
  final int? totalTayo;
  final List<String>? students;
  final String? studyLevel;

  GroupModel({
    this.gid,
    this.name,
    this.totalTayo,
    this.students,
    this.studyLevel,
  });

  factory GroupModel.fromJson(Map<String, dynamic> map, String mid) {
    return GroupModel(
      gid: mid,
      name: map['name'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,
      students: map['students'] is List
          ? List<String>.from(map['students'])
          : const <String>[],
      studyLevel: map['studyLevel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalTayo': totalTayo,
      'students': students,
      'studyLevel': studyLevel,
    };
  }

  GroupModel copyWith({
    String? mid,
    String? name,
    int? totalTayo,
    List<String>? students,
    String? studyLevel,
  }) {
    return GroupModel(
      gid: gid,
      name: name ?? this.name,
      totalTayo: totalTayo ?? this.totalTayo,
      students: students ?? this.students,
      studyLevel: studyLevel ?? this.studyLevel,
    );
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (totalTayo != null) data['totalTayo'] = totalTayo;
    if (students != null) data['students'] = students;
    if (studyLevel != null) data['studyLevel'] = studyLevel;
    return data;
  }
}
