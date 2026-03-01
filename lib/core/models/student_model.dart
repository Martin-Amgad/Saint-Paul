import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? uid;
  final String? name;
  final String? motherPhone;
  final String? fatherPhone;
  final String? personalPhone;
  final String? housePhone;
  final String? address;
  final DateTime? birthday;
  final String? studyLevel;
  final String? responsibleTeacher;
  final String? avatarUrl;
  final int? totalTayo;
  final Map<String, dynamic>? tayo;
  final List<String>? missionBadges;
  final List<String>? acceptedMissions;
  final Map<String, dynamic>? submittedMissions;
  final String? groupID;

  StudentModel({
    this.uid,
    this.name,
    this.motherPhone,
    this.fatherPhone,
    this.personalPhone,
    this.housePhone,
    this.address,
    this.avatarUrl,
    this.totalTayo = 0,
    this.birthday,
    this.studyLevel,
    this.responsibleTeacher,
    this.tayo = const {
      'حضور القداس': {'count': 0, 'takenAt': null},
      'حضور القداس قبل المستر': {'count': 0, 'takenAt': null},
      'هدوء و مفتحش الموبيل في القداس': {'count': 0, 'takenAt': null},
      'دخل الاجتماع من 11:30 ل 11:40 صباحا': {'count': 0, 'takenAt': null},
      'سلوك كويس في الاجتماع': {'count': 0, 'takenAt': null},
      'مفتحش الموبيل و الفقرة شغالة': {'count': 0, 'takenAt': null},
      'اجابة علي سؤال في الدرس': {'count': 0, 'takenAt': null},
    },
    this.missionBadges = const [],
    this.acceptedMissions = const [],
    this.submittedMissions = const {},
    this.groupID,
  });

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'motherPhone': motherPhone,
      'fatherPhone': fatherPhone,
      'personalPhone': personalPhone,
      'housePhone': housePhone,
      'address': address,
      'avatarUrl': avatarUrl,
      'totalTayo': totalTayo,
      'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
      'studyLevel': studyLevel,
      'responsibleTeacher': responsibleTeacher,
      'tayo': tayo,
      'missionBadges': missionBadges,
      'acceptedMissions': acceptedMissions,
      'submittedMissions': submittedMissions,
      'groupID': groupID,
    };
  }

  /// Model → local (without nulls)

  Map<String, dynamic> toJsonLocal() {
    return {
      'name': name,
      'motherPhone': motherPhone,
      'fatherPhone': fatherPhone,
      'personalPhone': personalPhone,
      'housePhone': housePhone,
      'address': address,
      'avatarUrl': avatarUrl,
      'totalTayo': totalTayo,
      'studyLevel': studyLevel,
      'responsibleTeacher': responsibleTeacher,
      'tayo': tayo?.map(
        (key, value) => MapEntry(key, {
          'count': value['count'],
          'takenAt': value['takenAt'] == null
              ? null
              : value['takenAt'] is Timestamp
              ? (value['takenAt'] as Timestamp).millisecondsSinceEpoch
              : value['takenAt'],
        }),
      ),
      'missionBadges': missionBadges,
      'acceptedMissions': acceptedMissions,
      'submittedMissions': submittedMissions?.map(
        (missionId, missionMap) => MapEntry(
          missionId,
          missionMap, // ← just pass it as-is, no nested conversion needed
        ),
      ),
      'groupID': groupID,
    };
  }

  /// Firestore → Model
  factory StudentModel.fromJson(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      motherPhone: map['motherPhone'] ?? '',
      fatherPhone: map['fatherPhone'] ?? '',
      personalPhone: map['personalPhone'] ?? '',
      housePhone: map['housePhone'] ?? '',
      address: map['address'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,
      birthday: map['birthday'] != null
          ? (map['birthday'] as Timestamp).toDate()
          : null,

      studyLevel: map['studyLevel'] ?? '',
      responsibleTeacher: map['responsibleTeacher'] ?? 'لا يوجد',
      tayo: map['tayo'] as Map<String, dynamic>? ?? {},
      missionBadges: map['missionBadges'] is List
          ? List<String>.from(map['missionBadges'])
          : const <String>[],
      acceptedMissions: map['acceptedMissions'] is List
          ? List<String>.from(map['acceptedMissions'])
          : const <String>[],
      submittedMissions:
          (map['submittedMissions'] as Map<String, dynamic>? ?? {}).map(
            (missionId, missionMap) => MapEntry(
              missionId,
              (missionMap as Map<String, dynamic>).map((title, details) {
                final d = Map<String, dynamic>.from(details as Map);
                return MapEntry(title, {
                  ...d,
                  'currentDate':
                      d['currentDate'], // already int, no conversion needed
                });
              }),
            ),
          ),
      groupID: map['groupID'],
    );
  }

  /// Firestore → Model for local (without nulls)
  factory StudentModel.fromJsonLocal(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      motherPhone: map['motherPhone'] ?? '',
      fatherPhone: map['fatherPhone'] ?? '',
      personalPhone: map['personalPhone'] ?? '',
      housePhone: map['housePhone'] ?? '',
      address: map['address'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,

      studyLevel: map['studyLevel'] ?? '',
      responsibleTeacher: map['responsibleTeacher'] ?? 'لا يوجد',
      tayo: (map['tayo'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, {
          'count': value['count'],
          'takenAt': value['takenAt'] == null
              ? null
              : value['takenAt'] is int
              ? value['takenAt'] // stored as milliseconds
              : value['takenAt'],
        }),
      ),
      missionBadges: map['missionBadges'] is List
          ? List<String>.from(map['missionBadges'])
          : const <String>[],
      acceptedMissions: map['acceptedMissions'] is List
          ? List<String>.from(map['acceptedMissions'])
          : const <String>[],
      submittedMissions:
          (map['submittedMissions'] as Map<String, dynamic>? ?? {}).map(
            (missionId, missionMap) => MapEntry(
              missionId,
              Map<String, dynamic>.from(
                missionMap as Map,
              ), // ← just cast it, no nested loop
            ),
          ),
      groupID: map['groupID'],
    );
  }

  /// CopyWith
  StudentModel copyWith({
    String? name,
    String? motherPhone,
    String? fatherPhone,
    String? personalPhone,
    String? housePhone,
    String? address,
    String? avatarUrl,
    int? totalTayo,
    DateTime? birthday,
    String? studyLevel,
    String? responsibleTeacher,
    Map<String, dynamic>? tayo,
    List<String>? missionBadges,
    List<String>? acceptedMissions,
    Map<String, dynamic>? submittedMissions,
    String? groupID,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      motherPhone: motherPhone ?? this.motherPhone,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      personalPhone: personalPhone ?? this.personalPhone,
      housePhone: housePhone ?? this.housePhone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalTayo: totalTayo ?? this.totalTayo,
      birthday: birthday ?? this.birthday,
      studyLevel: studyLevel ?? this.studyLevel,
      responsibleTeacher: responsibleTeacher ?? this.responsibleTeacher,
      tayo: tayo ?? this.tayo,
      missionBadges: missionBadges ?? this.missionBadges,
      acceptedMissions: acceptedMissions ?? this.acceptedMissions,
      submittedMissions: submittedMissions ?? this.submittedMissions,
      groupID: groupID ?? this.groupID,
    );
  }

  /// Partial update for Firestore
  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (motherPhone != null) data['motherPhone'] = motherPhone;
    if (fatherPhone != null) data['fatherPhone'] = fatherPhone;
    if (personalPhone != null) data['personalPhone'] = personalPhone;
    if (housePhone != null) data['housePhone'] = housePhone;
    if (address != null) data['address'] = address;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (totalTayo != null) data['totalTayo'] = totalTayo;
    if (birthday != null) data['birthday'] = Timestamp.fromDate(birthday!);
    if (studyLevel != null) data['studyLevel'] = studyLevel;
    if (responsibleTeacher != null) {
      data['responsibleTeacher'] = responsibleTeacher;
    }
    if (tayo != null) data['tayo'] = tayo;
    if (missionBadges != null) data['missionBadges'] = missionBadges;
    if (acceptedMissions != null) {
      data['acceptedMissions'] = acceptedMissions;
    }
    if (submittedMissions != null) {
      data['submittedMissions'] = submittedMissions;
    }
    if (groupID != null) {
      data['groupID'] = groupID;
    }
    return data;
  }
}
