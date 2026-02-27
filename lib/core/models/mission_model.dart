import 'package:cloud_firestore/cloud_firestore.dart';

class MissionModel {
  final String? mid;
  final String? title;
  final String? description;
  final String? link;
  final String? reward;
  final int? expireAfter;
  final DateTime? currentDate;
  final String? studentSolution;

  MissionModel({
    this.mid,
    this.title,
    this.description,
    this.link,
    this.reward,
    this.expireAfter,
    this.currentDate,
    this.studentSolution,
  });

  factory MissionModel.fromJson(Map<String, dynamic> map, String mid) {
    return MissionModel(
      mid: mid,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      link: map['link'] ?? '',
      reward: map['reward'] ?? '0',
      expireAfter: map['expireAfter'] ?? 0,
      currentDate: map['currentDate'] != null
          ? (map['currentDate'] as Timestamp).toDate()
          : null,
      studentSolution: map['studentSolution'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': mid,
      'title': title,
      'description': description,
      'link': link,
      'reward': reward,
      'expireAfter': expireAfter,
      'currentDate': currentDate != null
          ? Timestamp.fromDate(currentDate!)
          : null,
      'studentSolution': studentSolution,
    };
  }

  MissionModel copyWith({
    String? mid,
    String? title,
    String? description,
    String? link,
    String? reward,
    int? expireAfter,
    DateTime? currentDate,
    String? studentSolution,
  }) {
    return MissionModel(
      mid: mid ?? this.mid,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      reward: reward ?? this.reward,
      expireAfter: expireAfter ?? this.expireAfter,
      currentDate: currentDate ?? this.currentDate,
      studentSolution: studentSolution ?? this.studentSolution,
    );
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (link != null) data['link'] = link;
    if (reward != null) data['reward'] = reward;
    if (expireAfter != null) data['expireAfter'] = expireAfter;
    if (currentDate != null)
      data['currentDate'] = Timestamp.fromDate(currentDate!);
    if (studentSolution != null) data['studentSolution'] = studentSolution;
    return data;
  }
}
