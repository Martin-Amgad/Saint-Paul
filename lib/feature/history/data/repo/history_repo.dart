import 'dart:developer';

import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

class HistoryRepo {
  static Future<List<TayoHistoryModel>> loadTayoHistory(
    String studentId,
  ) async {
    try {
      final querySnapshot = await FirebaseProvider.getStudentTayoHistory(
        studentId,
      );
      final historyList = querySnapshot.docs
          .map((doc) => TayoHistoryModel.fromJson(doc.data(), doc.id))
          .toList();
      log('✅ Loaded ${historyList.length} history entries');
      return historyList;
    } catch (e) {
      log('❌ loadHistory failed: $e');
      return [];
    }
  }

  static Future<List<TayoHistoryModel>> loadPointsHistory(
    String groupId,
  ) async {
    try {
      final querySnapshot = await FirebaseProvider.getGroupPointsHistory(
        groupId,
      );
      final historyList = querySnapshot.docs
          .map((doc) => TayoHistoryModel.fromJson(doc.data(), doc.id))
          .toList();
      log('✅ Loaded ${historyList.length} history entries');
      return historyList;
    } catch (e) {
      log('❌ loadHistory failed: $e');
      return [];
    }
  }
}
