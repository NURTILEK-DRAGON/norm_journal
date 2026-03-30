import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/pages/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Временная модель данных для старосты
class Monitor {
  final String name;
  final String group;

  Monitor({
    required this.name, 
    required this.group,
});
}

class MonitorsListPage extends StatefulWidget {

  final Function(Locale) changeLanguage;
  final ScheduleRepository scheduleRepository;

  
  const MonitorsListPage({
    super.key,
    required this.changeLanguage,
    required this.scheduleRepository,});

  @override
  State<MonitorsListPage> createState() => _MonitorsListPageState();
}

class _MonitorsListPageState extends State<MonitorsListPage> {
  // Список-заглушка
  final List<Monitor> allMonitors = [
    Monitor(name: 'Nurtilek', group: 'РМП-24'),
    Monitor(name: 'Aziret', group: 'BD-24')
  ];

  // Список для отображения (с учетом поиска)
  List<Monitor> filteredMonitors = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    filteredMonitors = allMonitors; // Изначально показываем всех
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Список групп (старост)'),
      backgroundColor: Colors.indigo,
    ),
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getMonitorsStream(),
      builder: (context, snapshot) {
        // 1. Пока данные грузятся
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Если произошла ошибка
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        // 3. Если данных нет
        final monitors = snapshot.data ?? [];
        if (monitors.isEmpty) {
          return const Center(child: Text('Старосты еще не зарегистрировались'));
        }

        // 4. Отображаем реальный список из Firebase
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: monitors.length,
          itemBuilder: (context, index) {
            final data = monitors[index];
            final String name = data['name'] ?? 'Без имени';
            final String group = data['group_id'] ?? 'Без группы';

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(group.isNotEmpty ? group[0] : '?'),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Группа: $group'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  // Сохраняем выбранную группу в префы, чтобы календарь её видел
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('group_id', group);

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarPage(
                          changeLanguage: widget.changeLanguage,
                          scheduleRepository: widget.scheduleRepository,
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    ),
  );
}
}