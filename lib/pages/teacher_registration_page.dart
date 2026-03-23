// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:norm_journal/constant_subjects.dart';

class TeacherRegistrationPage extends StatefulWidget {
  const TeacherRegistrationPage({super.key});

  @override
  State<TeacherRegistrationPage> createState() => _TeacherRegistrationPageState();
}

class _TeacherRegistrationPageState extends State<TeacherRegistrationPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final List<String> _selectedSubjects = [];

  void _onSubjectTap(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        if (_selectedSubjects.length < 2) {
          _selectedSubjects.add(subject);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Можно выбрать не более 2-х предметов'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  bool _isFormValid() {
    return _firstNameController.text.isNotEmpty &&
           _lastNameController.text.isNotEmpty &&
           _selectedSubjects.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация учителя'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите ваши данные',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Фамилия',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 30),
            Text(
              'Выберите предметы (макс. 2): ${_selectedSubjects.length}/2',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              height: 300, 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: ConstantSubjects.availableSubjects.length,
                itemBuilder: (context, index) {
                  final subject = ConstantSubjects.availableSubjects[index];
                  final isSelected = _selectedSubjects.contains(subject);
                  return CheckboxListTile(
                    title: Text(subject),
                    value: isSelected,
                    activeColor: Colors.indigo,
                    onChanged: (bool? value) => _onSubjectTap(subject),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isFormValid() ? () {
                  print('Регистрация: ${_firstNameController.text} ${_lastNameController.text}');
                  print('Предметы: $_selectedSubjects');
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}