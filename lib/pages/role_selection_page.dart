import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'register_monitor_page.dart';
import 'register_teacher_page.dart';

class RoleSelectionPage extends StatelessWidget {
  final ScheduleRepository? scheduleRepository;

  const RoleSelectionPage({super.key, this.scheduleRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                'Кто вы?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Выберите вашу роль для настройки профиля'),
              const SizedBox(height: 40),

              // Кнопка Старосты
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Я Староста', style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterMonitorPage(scheduleRepository: scheduleRepository),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Кнопка Учителя
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.assignment_ind, color: Colors.white),
                label: const Text('Я Преподаватель', style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterTeacherPage(scheduleRepository: scheduleRepository),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}