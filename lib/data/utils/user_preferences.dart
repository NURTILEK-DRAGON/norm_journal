import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyIsTeacher = 'is_teacher';
  static const String _keySubjects = 'teacher_subjects';
  static const String _keyIsRegistered = 'is_registered'; // Чтобы больше не показывать экран выбора

  // Сохраняем данные
  static Future<void> saveUser(bool isTeacher, {List<String> subjects = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsTeacher, isTeacher);
    await prefs.setStringList(_keySubjects, subjects);
    await prefs.setBool(_keyIsRegistered, true);
  }

  // Проверяем, заходил ли пользователь раньше
  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsRegistered) ?? false;
  }

  // Узнаем, учитель ли это
  static Future<bool> isTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsTeacher) ?? false;
  }

  // Получаем список предметов учителя
  static Future<List<String>> getTeacherSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySubjects) ?? [];
  }
  
  // Кнопка "Выйти" (для тестов пригодится)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Очистит всё
  }
}