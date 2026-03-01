import 'dart:developer';

import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

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

  static Future<String?> updateMission(MissionModel mission) async {
    try {
      await FirebaseProvider.updateMission(mission);
      return 'تم تحديث المهمة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث المهمة. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث المهمة. الرجاء المحاولة مرة أخرى.';
    }
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

  static Future<List<String>> fetchAcceptedMissions() async {
    try {
      final studentSnapshot = await FirebaseProvider.getStudentByID(
        LocalHelper.getUserId(),
      );
      log(
        'Fetched student snapshot: ${studentSnapshot.id} → ${studentSnapshot.data()}',
      );

      final data = ((studentSnapshot.data()) as Map<String, dynamic>?) ?? {};
      log('Student data: $data');

      final acceptedMissions =
          (data['acceptedMissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      log('Accepted missions from student data: $acceptedMissions');
      return acceptedMissions;
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<List<String>> fetchSubmittedMissions() async {
    try {
      final studentSnapshot = await FirebaseProvider.getStudentByID(
        LocalHelper.getUserId(),
      );

      final data = studentSnapshot.data() as Map<String, dynamic>? ?? {};

      return (data['submittedMissions'] as Map<String, dynamic>?)?.keys
              .toList() ??
          [];
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<String?> acceptMission(String mid) async {
    try {
      final userId = LocalHelper.getUserId();
      await FirebaseProvider.updateAcceptedMissions(userId, mid);
      return 'تم قبول المهمة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء قبول المهمة. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء قبول المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> submitMission(String mid, MissionModel mission) async {
    try {
      final userId = LocalHelper.getUserId();
      await FirebaseProvider.updateSubmittedMissions(userId, mid, mission);
      return 'تم إرسال المهمة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إرسال المهمة. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إرسال المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }
}

int daysLeft(MissionModel m) {
  if (m.currentDate == null || m.expireAfter == null) return 0;
  final expireDate = m.currentDate!.add(Duration(days: m.expireAfter!));
  return expireDate.difference(DateTime.now()).inDays;
}
