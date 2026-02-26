import 'dart:developer';

import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

class MissionRepo {
  static Future<String?> createMission(MissionModel mission) async {
    try {
      await FirebaseProvider.createMission(mission);
      return 'تم إنشاء المهمة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إنشاء المهمة. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إنشاء المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> deleteMission(String missionId) async {
    try {
      await FirebaseProvider.deleteMission(missionId);
      return 'تم حذف المهمة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء حذف المهمة. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء حذف المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<void> updateMission(
    String missionId,
    Map<String, dynamic> updatedData,
  ) async {
    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 2));
    // Here you would typically send the updatedData to your backend or database using the missionId
    log('Mission with ID $missionId updated with data: $updatedData');
  }

  static Future<List<MissionModel>> fetchMissions() async {
    try {
      final snapshot = await FirebaseProvider.fetchMissions();
      log('Fetched missions snapshot: ${snapshot.docs.length} documents');
      try {
        final missions = snapshot.docs.map((doc) {
          log('Parsing doc: ${doc.id} → ${doc.data()}');
          return MissionModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
        log('Parsed missions: ${missions.length} missions');

        missions.sort((a, b) => daysLeft(b).compareTo(daysLeft(a)));
        return missions;
      } on Exception catch (e) {
        log('Error sorting missions: ${e.toString()}');
        return [];
      }
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

int daysLeft(MissionModel m) {
  if (m.currentDate == null || m.expireAfter == null) return 0;
  final expireDate = m.currentDate!.add(Duration(days: m.expireAfter!));
  return expireDate.difference(DateTime.now()).inDays;
}
