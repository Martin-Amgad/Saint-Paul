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
    };
  }

  /// Firestore → Model
  factory StudentModel.fromJson(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      motherPhone: map['motherPhone'] ?? 'لا يوجد',
      fatherPhone: map['fatherPhone'] ?? 'لا يوجد',
      personalPhone: map['personalPhone'] ?? 'لا يوجد',
      housePhone: map['housePhone'] ?? 'لا يوجد',
      address: map['address'] ?? 'لا يوجد',
      avatarUrl: map['avatarUrl'] ?? '',
      totalTayo: map['totalTayo'] ?? 0,
      birthday: map['birthday'] != null
          ? (map['birthday'] as Timestamp).toDate()
          : null,

      studyLevel: map['studyLevel'] ?? '',
      responsibleTeacher: map['responsibleTeacher'] ?? 'لا يوجد',
      tayo: map['tayo'] as Map<String, dynamic>? ?? {},
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

    return data;
  }
}
