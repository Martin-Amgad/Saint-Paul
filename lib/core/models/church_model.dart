class ChurchModel {
  final String? churchId;
  final String? adminPin;
  final String? churchName;
  final Map<String, dynamic>? points;
  final Map<String, dynamic>? tayo;

  ChurchModel({
    this.churchId,
    this.adminPin,
    this.churchName,
    this.points,
    this.tayo,
  });

  factory ChurchModel.fromJson(Map<String, dynamic> map, String cid) {
    return ChurchModel(
      churchId: cid,
      adminPin: map['adminPin'] ?? '',
      churchName: map['churchName'] ?? '',
      points: map['points'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['points'])
          : <String, dynamic>{},
      tayo: map['tayo'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['tayo'])
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminPin': adminPin,
      'churchName': churchName,
      'points': points,
      'tayo': tayo,
    };
  }

  ChurchModel copyWith({
    String? churchId,
    String? adminPin,
    String? churchName,
    Map<String, dynamic>? points,
    Map<String, dynamic>? tayo,
  }) {
    return ChurchModel(
      churchId: churchId ?? this.churchId,
      adminPin: adminPin ?? this.adminPin,
      churchName: churchName ?? this.churchName,
      points: points ?? this.points,
      tayo: tayo ?? this.tayo,
    );
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (adminPin != null) data['adminPin'] = adminPin;
    if (churchName != null) data['churchName'] = churchName;
    if (points != null) data['points'] = points;
    if (tayo != null) data['tayo'] = tayo;

    return data;
  }
}
