import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/pages/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterMonitorPage extends StatefulWidget {
  final ScheduleRepository? scheduleRepository;
  final Function(Locale)? changeLanguage;

  const RegisterMonitorPage({
    super.key, 
    this.scheduleRepository,
    required this.changeLanguage,
  });

  @override
  State<RegisterMonitorPage> createState() => _RegisterMonitorPageState();
}

class _RegisterMonitorPageState extends State<RegisterMonitorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

   Widget _buildLanguagePicker() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.language, 
        color: Colors.green),
      onSelected: (val) => widget.changeLanguage!(
        val == 'en' ? const Locale('en') : const Locale('ru'),
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'ru', child: Text('Русский')),
      ],
    );
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text(
        'Регистрация старосты', 
        style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [_buildLanguagePicker()],
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.group_add_rounded, size: 50, color: Colors.green),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  l10n.fullName, Icons.person_outline, Colors.green),
                validator: (v) => v!.isEmpty ? l10n.enterFullName : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _groupController,
                decoration: _inputDecoration(
                  l10n.groupNameLabel, 
                  Icons.diversity_3_outlined, Colors.green),
                validator: (v) => v!.isEmpty ? l10n.enterGroupName : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  onPressed: _register,
                  child: Text(
                    l10n.register, 
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: color, width: 2)),
    );
  }
}