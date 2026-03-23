import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/constant_subjects.dart';
import 'package:norm_journal/pages/calendar_page.dart'; 

class RoleSelectionPage extends StatefulWidget {

  final ScheduleRepository? scheduleRepository;

  const RoleSelectionPage({
    super.key,
    this.scheduleRepository});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool isTeacherSelected = false;
  List<String> selectedSubjects = [];
 
  final List<String> allSubjects = ConstantSubjects.availableSubjects;

  Future<void> _saveAndContinue() async {

    if (isTeacherSelected && selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите хотя бы один предмет')),
      );
      return;
    }
    await UserPreferences.saveUser(isTeacherSelected, subjects: selectedSubjects);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage(
          scheduleRepository: widget.scheduleRepository!,
          changeLanguage: (Locale locale) {},
         )
         ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добро пожаловать'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Выберите вашу роль:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Кнопка Старосты
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !isTeacherSelected ? Colors.green : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => setState(() => isTeacherSelected = false),
              child: const Text('Я Староста', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 10),

            // Кнопка Учителя
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isTeacherSelected ? Colors.blue : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => setState(() => isTeacherSelected = true),
              child: const Text('Я Преподаватель', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            
            const SizedBox(height: 20),

            // Список предметов (показываем только если выбран учитель)
            if (isTeacherSelected) ...[
              const Text('Какие предметы вы ведете?', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: allSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = allSubjects[index];
                    return CheckboxListTile(
                      title: Text(subject),
                      value: selectedSubjects.contains(subject),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedSubjects.add(subject);
                          } else {
                            selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              const Spacer(), // Заполняем пустоту, если староста
            ],

            ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Продолжить', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}