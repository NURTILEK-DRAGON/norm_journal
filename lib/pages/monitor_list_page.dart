import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/pages/calendar_page.dart';

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
  final List<String> teacherSubjects;
  
  const MonitorsListPage({
    super.key,
    required this.changeLanguage,
    required this.scheduleRepository,
    required this.teacherSubjects,});

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredMonitors = allMonitors; // Изначально показываем всех
  }

  void _filterMonitors(String query) {
    setState(() {
      filteredMonitors = allMonitors
          .where((m) =>
              m.name.toLowerCase().contains(query.toLowerCase()) ||
              m.group.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список старост'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMonitors,
              decoration: InputDecoration(
                labelText: 'Поиск по группе или имени',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Список старост
          Expanded(
            child: filteredMonitors.isEmpty
                ? const Center(child: Text('Старосты не найдены'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredMonitors.length,
                    itemBuilder: (context, index) {
                      final monitor = filteredMonitors[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              monitor.group[0], // Первая буква группы
                              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            monitor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            'Группа: ${monitor.group}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: 
                                (context) =>  CalendarPage(
                                  changeLanguage: widget.changeLanguage, 
                                  scheduleRepository: widget.scheduleRepository,
                                  isTeacher: true,
                                  teacherSubjects: widget.teacherSubjects,
                                  monitorId: monitor.name,
                                  )
                                  )
                                  );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}