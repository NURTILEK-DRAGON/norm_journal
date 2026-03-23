import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';

class AttendancePage extends StatefulWidget {
  final int date;
  final int month;
  final int year;
  final String lesson;
  final String? displayLesson;
  final List<String> students;
  final bool isGroupLesson;
  final Map<String, dynamic>? groupData;

  const AttendancePage({
    super.key,
    required this.date,
    required this.month,
    required this.year,
    required this.lesson,
    this.displayLesson,
    required this.students,
    this.isGroupLesson = false,
    this.groupData,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> attendance = [];
  List<String> currentStudents = [];
  String? selectedGroup; // '1' или '2'

  @override
  void initState() {
    super.initState();
    if (widget.isGroupLesson && widget.groupData != null) {
      _showGroupSelectionDialog();
    } else {
      currentStudents = widget.students;
      _loadAttendance();
    }
  }

  // Показываем выбор группы при первом входе
  Future<void> _showGroupSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Выберите группу', textAlign: TextAlign.center),
        content: const Text('Этот урок разделён на две группы.\nВыберите, с какой группой работаете сейчас:'),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Navigator.pop(context, '1'),
              child: const Text('Группа 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () => Navigator.pop(context, '2'),
              child: const Text('Группа 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (selected == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      selectedGroup = selected;
      final groupList = widget.groupData!['group$selected'] as List<dynamic>? ?? [];
      currentStudents = groupList.cast<String>();
    });

    _loadAttendance();
  }

  // Переключение группы из AppBar
  void _switchGroup() {
    final newGroup = selectedGroup == '1' ? '2' : '1';

    setState(() {
      selectedGroup = newGroup;
      final groupList = widget.groupData!['group$selectedGroup'] as List<dynamic>? ?? [];
      currentStudents = groupList.cast<String>();
      attendance.clear();
    });

    _loadAttendance();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Переключено на Группу $newGroup'),
        backgroundColor: newGroup == '1' ? Colors.blue : Colors.purple,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getKey() {
    return '${widget.year}-${widget.month}-${widget.date}-${widget.lesson}';
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey();

      List<Map<String, dynamic>> loadedAttendance = [];

      if (prefs.containsKey(key)) {
        final allLoaded = (jsonDecode(prefs.getString(key)!) as List<dynamic>)
            .map((x) => Map<String, dynamic>.from(x as Map))
            .toList();

        loadedAttendance = allLoaded.where((a) => currentStudents.contains(a['name'])).toList();
      }

      for (var student in currentStudents) {
        if (!loadedAttendance.any((a) => a['name'] == student)) {
          loadedAttendance.add({
            'name': student,
            'present': false,
            'absent': false,
            'sick': false,
            'documented': false,
            'lateTime': null,
          });
        }
      }

      loadedAttendance.sort((a, b) => currentStudents.indexOf(a['name']).compareTo(currentStudents.indexOf(b['name'])));

      if (mounted) {
        setState(() {
          attendance = loadedAttendance;
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  Future<void> _saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey();

      List<Map<String, dynamic>> allAttendance = [];
      if (prefs.containsKey(key)) {
        allAttendance = (jsonDecode(prefs.getString(key)!) as List<dynamic>)
            .map((x) => Map<String, dynamic>.from(x as Map))
            .toList();
      }

      for (var record in attendance) {
        final index = allAttendance.indexWhere((e) => e['name'] == record['name']);
        if (index != -1) {
          allAttendance[index] = record;
        } else {
          allAttendance.add(record);
        }
      }

      await prefs.setString(key, jsonEncode(allAttendance));
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  void _toggleAttendance(int index, String status) {
    setState(() {
      final keys = ['present', 'absent', 'sick', 'documented'];
      for (var key in keys) {
        attendance[index][key] = (key == status);
      }
      if (status != 'present') attendance[index]['present'] = false;
      if (status != 'absent') attendance[index]['absent'] = false;
      if (status != 'sick') attendance[index]['sick'] = false;
      if (status != 'documented') attendance[index]['documented'] = false;
    });
    _saveAttendance();
  }

  Future<void> _setLateTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() {
        attendance[index]['lateTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
      _saveAttendance();
    }
  }

  Future<void> _editOrRemoveLateTime(int index) async {
    final current = attendance[index]['lateTime'] as String?;
    final initial = current != null
        ? TimeOfDay(hour: int.parse(current.split(':')[0]), minute: int.parse(current.split(':')[1]))
        : TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Опоздание'),
        content: Text(current == null ? 'Установить время опоздания' : 'Время: $current'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          if (current != null)
            TextButton(
              onPressed: () {
                setState(() => attendance[index]['lateTime'] = null);
                _saveAttendance();
                Navigator.pop(context);
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final time = await showTimePicker(context: context, initialTime: initial);
              if (time != null) {
                setState(() {
                  attendance[index]['lateTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                });
                _saveAttendance();
              }
            },
            child: Text(current == null ? 'Установить' : 'Изменить'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    final l10n = AppLocalizations.of(context);
    return switch (month) {
      1 => l10n.month01,
      2 => l10n.month02,
      3 => l10n.month03,
      4 => l10n.month04,
      5 => l10n.month05,
      6 => l10n.month06,
      7 => l10n.month07,
      8 => l10n.month08,
      9 => l10n.month09,
      10 => l10n.month10,
      11 => l10n.month11,
      12 => l10n.month12,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = widget.displayLesson ?? widget.lesson.replaceAll('lesson', 'Урок ');

    final title = widget.isGroupLesson && selectedGroup != null
        ? '$displayTitle — Группа $selectedGroup'
        : displayTitle;

    final presentCount = attendance.where((a) => a['present'] == true).length;
    final absentCount = attendance.where((a) => a['absent'] == true).length;
    final sickCount = attendance.where((a) => a['sick'] == true).length;
    final documentedCount = attendance.where((a) => a['documented'] == true).length;
    final lateCount = attendance.where((a) => a['lateTime'] != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('$title - ${_getMonthName(widget.month)} ${widget.date}'),
        backgroundColor: selectedGroup == '1' ? Colors.blueAccent : Colors.purpleAccent,
        actions: [
          // Кнопка смены группы
          if (widget.isGroupLesson && selectedGroup != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
              tooltip: 'Сменить группу',
              onPressed: _switchGroup,
            ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Сохранить',
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: attendance.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: attendance.length + 1,
                itemBuilder: (context, index) {
                  if (index == attendance.length) {
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _stat(l10n.presentLabel, presentCount, Colors.green),
                            _stat(l10n.absentLabel, absentCount, Colors.red),
                            _stat(l10n.sickLabel, sickCount, Colors.orange),
                            _stat(l10n.documentedLabel, documentedCount, Colors.blue),
                            _stat(l10n.lateLabel, lateCount, Colors.purple),
                          ],
                        ),
                      ),
                    );
                  }

                  final record = attendance[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(record['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(record['present'], Icons.check_circle, Colors.green, () => _toggleAttendance(index, 'present')),
                          _iconButton(record['absent'], Icons.cancel, Colors.red, () => _toggleAttendance(index, 'absent')),
                          _iconButton(record['sick'], Icons.sick, Colors.orange, () => _toggleAttendance(index, 'sick')),
                          _iconButton(record['documented'], Icons.description, Colors.blue, () => _toggleAttendance(index, 'documented')),
                          record['lateTime'] == null
                              ? IconButton(icon: const Icon(Icons.access_time), onPressed: () => _setLateTime(index))
                              : GestureDetector(
                                  onTap: () => _editOrRemoveLateTime(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(20)),
                                    child: Text(record['lateTime'], style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _iconButton(bool active, IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: active ? color : Colors.grey),
      onPressed: onTap,
    );
  }

  Widget _stat(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        // ignore: deprecated_member_use
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
      ],
    );
  }
}