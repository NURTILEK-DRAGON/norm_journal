import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  // Получаем доступ к нашей базе данных
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _logger = Logger();

  // 1. Метод для сохранения Старосты
  Future<void> saveMonitor({
    required String name, 
    required String groupId
  }) async {
    try {
      // Создаем документ в коллекции 'users'
      await _db.collection('users').add({
        'name': name,
        'role': 'monitor',
        'group_id': groupId,
        'created_at': FieldValue.serverTimestamp(), // Время регистрации
      });
      _logger.i('Староста $name ($groupId) успешно сохранен в Firestore');
    } catch (e) {
      _logger.e('Ошибка при сохранении старосты: $e');
      rethrow;
    }
  }

  // 2. Метод для сохранения Преподавателя
  Future<void> saveTeacher({
    required String name, 
    required List<String> subjects
  }) async {
    try {
      await _db.collection('users').add({
        'name': name,
        'role': 'teacher',
        'subjects': subjects,
        'created_at': FieldValue.serverTimestamp(),
      });
      _logger.i('Преподаватель $name успешно сохранен в Firestore');
    } catch (e) {
      _logger.e('Ошибка при сохранении преподавателя: $e');
      rethrow;
    }
  }

  // Метод для получения списка всех старост
Stream<List<Map<String, dynamic>>> getMonitorsStream() {
  return _db
      .collection('users')
      .where('role', isEqualTo: 'monitor') // Забираем только старост
      .snapshots() // Подписываемся на обновления в реальном времени
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

// 1. Сохраняем список студентов для конкретной группы
Future<void> saveStudentList(String groupId, List<String> students) async {
  try {
    // Мы создаем (или обновляем) документ, где ID документа — это название группы
    await _db.collection('groups').doc(groupId).set({
      'group_id': groupId,
      'students': students,
      'last_updated': FieldValue.serverTimestamp(),
    });
    _logger.i('Список студентов группы $groupId обновлен в Firestore');
  } catch (e) {
    _logger.e('Ошибка сохранения студентов: $e');
    rethrow;
  }
}

// 2. Получаем список студентов группы
Future<List<String>> getStudentList(String groupId) async {
  try {
    DocumentSnapshot doc = await _db.collection('groups').doc(groupId).get();
    if (doc.exists) {
      List<dynamic> data = doc.get('students');
      return data.cast<String>();
    }
    return [];
  } catch (e) {
    _logger.e('Ошибка получения студентов: $e');
    return [];
  }
}
}