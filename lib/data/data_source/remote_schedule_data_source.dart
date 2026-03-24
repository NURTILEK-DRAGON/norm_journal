import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norm_journal/data/data_source/schedule_data_source.dart';

class RemoteScheduleDataSource implements ScheduleDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Загружаем расписание конкретной группы
  Future<Map<String, List<String>>> getSchedule(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) return {};

      // Конвертируем данные из Firestore (Map<String, dynamic>) в наш формат
      final data = doc.data()!['schedule'] as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      return {};
    }
  }

  // Сохраняем расписание в облако
  Future<void> saveSchedule(String groupId, Map<String, List<String>> schedule) async {
    await _firestore.collection('groups').doc(groupId).set({
      'schedule': schedule,
    }, SetOptions(merge: true)); // merge: true, чтобы не затереть другие данные группы
  }

  @override
  Future<List<ScheduleVersion>>loadVersions()async{
    return [];
  }

  Future<List<ScheduleVersion>> loadVersionsForGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists || doc.data()?['versions'] == null) return [];

      final List decoded = doc.data()!['versions'];
      return decoded.map((e) => ScheduleVersion.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveVersions(List<ScheduleVersion> versions)async{}

  Future<void> saveVersionsForGroup(String groupId, List<ScheduleVersion> versions) async {
    final encoded = versions.map((e) => e.toJson()).toList();
    await _firestore.collection('groups').doc(groupId).set({
      'versions': encoded,
    }, SetOptions(merge: true));
  }
}
  
  