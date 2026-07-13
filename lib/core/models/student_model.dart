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
  final Map<String, String>? myBadges;
  final List<String>? acceptedMissions;
  final Map<String, dynamic>? submittedMissions;
  final String? groupID;
  final String? family;
  final String? church;
  final DateTime? lastMissCheck;

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
    this.myBadges = const {},
    this.acceptedMissions = const [],
    this.submittedMissions = const {},
    this.groupID,
    this.family,
    this.church,
    this.lastMissCheck,
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
      'myBadges': myBadges,
      'acceptedMissions': acceptedMissions,
      'submittedMissions': submittedMissions,
      'groupID': groupID,
      'family': family,
      'church': church,
      'lastMissCheck': lastMissCheck != null
          ? Timestamp.fromDate(lastMissCheck!)
          : null,
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
      'myBadges': myBadges,
      'acceptedMissions': acceptedMissions,
      'submittedMissions': submittedMissions,
      'groupID': groupID,
      'family': family,
      'church': church,
      'lastMissCheck': lastMissCheck != null
          ? Timestamp.fromDate(lastMissCheck!)
          : null,
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
      myBadges: map['myBadges'] is Map
          ? Map<String, String>.from(map['myBadges'] as Map)
          : const <String, String>{},
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
      family: map['family'],
      church: map['church'],
      lastMissCheck: map['lastMissCheck'] != null
          ? (map['lastMissCheck'] as Timestamp).toDate()
          : null,
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
      myBadges: map['myBadges'] is Map
          ? Map<String, String>.from(map['myBadges'] as Map)
          : const <String, String>{},
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
      family: map['family'],
      church: map['church'],
      lastMissCheck: map['lastMissCheck'] != null
          ? (map['lastMissCheck'] is int
                ? DateTime.fromMillisecondsSinceEpoch(
                    map['lastMissCheck'] as int,
                  )
                : (map['lastMissCheck'] as Timestamp).toDate())
          : null,
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
    Map<String, String>? myBadges,
    List<String>? acceptedMissions,
    Map<String, dynamic>? submittedMissions,
    String? groupID,
    String? family,
    String? church,
    DateTime? lastMissCheck,
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
      myBadges: myBadges ?? this.myBadges,
      acceptedMissions: acceptedMissions ?? this.acceptedMissions,
      submittedMissions: submittedMissions ?? this.submittedMissions,
      groupID: groupID ?? this.groupID,
      family: family ?? this.family,
      church: church ?? this.church,
      lastMissCheck: lastMissCheck ?? this.lastMissCheck,
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
    if (myBadges != null) data['myBadges'] = myBadges;
    if (acceptedMissions != null) {
      data['acceptedMissions'] = acceptedMissions;
    }
    if (submittedMissions != null) {
      data['submittedMissions'] = submittedMissions;
    }
    if (groupID != null) {
      data['groupID'] = groupID;
    }
    if (family != null) {
      data['family'] = family;
    }
    if (church != null) {
      data['church'] = church;
    }
    if (lastMissCheck != null) {
      data['lastMissCheck'] = Timestamp.fromDate(lastMissCheck!);
    }

    return data;
  }
}
