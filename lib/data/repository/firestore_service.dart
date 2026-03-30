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
}