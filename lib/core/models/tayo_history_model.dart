import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class TayoHistoryModel {
  final String? uid;
  final String? category;
  final int? change;
  final DateTime? createdAt;
  final String? teacherName;

  const TayoHistoryModel({
    this.uid,
    required this.category,
    required this.change,
    this.createdAt,
    this.teacherName,
  });

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'category': category ?? 'غير معروف',
      'change': change ?? 0,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'teacherName': teacherName,
    };
  }

  /// Model → Local Storage
  Map<String, dynamic> toJsonLocal() {
    return {
      'category': category ?? 'غير معروف',
      'change': change ?? 0,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'teacherName': teacherName,
    };
  }

  /// Firestore → Model
  factory TayoHistoryModel.fromJson(Map<String, dynamic> map, String uid) {
    return TayoHistoryModel(
      uid: uid,
      category: map['category'] ?? '',
      change: map['change'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teacherName: map['teacherName'] ?? '',
    );
  }

  factory TayoHistoryModel.fromJsonLocal(Map<String, dynamic> map, String uid) {
    return TayoHistoryModel(
      uid: uid,
      category: map['category'] ?? '',
      change: map['change'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      teacherName: map['teacherName'] ?? '',
    );
  }

  TayoHistoryModel copyWith({
    String? uid,
    String? category,
    int? change,
    DateTime? createdAt,
    String? teacherName,
  }) {
    return TayoHistoryModel(
      uid: uid ?? this.uid,
      category: category ?? this.category,
      change: change ?? this.change,
      createdAt: createdAt ?? this.createdAt,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (category != null) data['category'] = category;
    if (change != null) data['change'] = change;
    if (createdAt != null) data['createdAt'] = Timestamp.fromDate(createdAt!);
    if (teacherName != null) data['teacherName'] = teacherName;
    return data;
  }

  static List<TayoHistoryModel> computeTayoChanges({
    required Map<String, dynamic> oldTayo,
    required Map<String, dynamic> newTayo,
    required List<String> removedCategories,
  }) {
    final changes = <TayoHistoryModel>[];

    for (final entry in newTayo.entries) {
      final category = entry.key;
      final newData = entry.value;

      // 1. Skip deleted categories
      if (removedCategories.contains(category)) continue;

      // Extract count, defaulting to 0 if missing
      final newCount = (newData['count'] as int?) ?? 0;

      if (oldTayo.containsKey(category)) {
        // 2. Existing category
        final oldData = oldTayo[category]!;
        final oldCount = (oldData['count'] as int?) ?? 0;
        final diff = newCount - oldCount;
        if (diff != 0) {
          changes.add(
            TayoHistoryModel(
              category: category,
              change: diff,
              createdAt: DateTime.now(),
              teacherName: LocalHelper.getTeacherName() ?? 'Unknown',
            ),
          );
        }
      } else {
        // 3. Brand‑new category (old count implicitly 0)
        if (newCount >= 0) {
          changes.add(
            TayoHistoryModel(
              category: category,
              change: newCount,
              createdAt: DateTime.now(),
              teacherName: LocalHelper.getTeacherName() ?? 'Unknown',
            ),
          );
        }
      }
    }

    return changes;
  }
}
