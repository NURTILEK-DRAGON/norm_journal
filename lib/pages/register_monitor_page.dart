import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/pages/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterMonitorPage extends StatefulWidget {
  final ScheduleRepository? scheduleRepository;
  const RegisterMonitorPage({super.key, this.scheduleRepository});

  @override
  State<RegisterMonitorPage> createState() => _RegisterMonitorPageState();
}

class _RegisterMonitorPageState extends State<RegisterMonitorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final groupId = _groupController.text.trim();

    try {
      // 1. Сохраняем или "входим" 
      await _firestoreService.saveMonitor(
        name: _nameController.text.trim(), 
        groupId: groupId
      );

      // 2. Пытаемся скачать список студентов из Firebase для этой группы
      final students = await _firestoreService.getStudentList(groupId);
      
      // 3. Сохраняем пользователя локально И передаем скачанных студентов (если они были)
      final prefs = await SharedPreferences.getInstance();
      if (students.isNotEmpty) {
        // Если студенты нашлись, сохраняем их в память телефона
        await prefs.setString('students', jsonEncode(students));
      } else {
        // Если студентов нет, очищаем старый список (на всякий случай)
        await prefs.remove('students');
      }

      await UserPreferences.saveUser(false, groupId);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarPage(
              scheduleRepository: widget.scheduleRepository!,
              changeLanguage: (l) {},
            ),
          ),
          (route) => false,
        );
      }
    } catch(e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(title: const Text('Регистрация старосты'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.green),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО', 
                  border: OutlineInputBorder(), 
                  prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Название группы', 
                  hintText: 'Например: РМП-24', 
                  border: OutlineInputBorder(), 
                  prefixIcon: Icon(Icons.group)),
                validator: (v) => v!.isEmpty ? 'Введите группу' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white),
                  onPressed: _register,
                  child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}