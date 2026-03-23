// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:journal_app/l10n/app_localizations.dart';

// class AttendancePage extends StatefulWidget {
//   final int date;
//   final int month;
//   final int year;
//   final String lesson; // например: lesson1, lesson2...
//   final String? displayLesson;
//   final List<String> students;

//   // Новые параметры для групповых уроков
//   final bool isGroupLesson;
//   final Map<String, dynamic>? groupData; // { 'group1': [...], 'group2': [...] }

//   const AttendancePage({
//     super.key,
//     required this.date,
//     required this.month,
//     required this.year,
//     required this.lesson,
//     this.displayLesson,
//     required this.students,
//     this.isGroupLesson = false,
//     this.groupData,
//   });

//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   List<Map<String, dynamic>> attendance = [];
//   List<String> currentStudents = [];
//   String? selectedGroup; // '1' или '2'

//   @override
//   void initState() {
//     super.initState();
//     if (widget.isGroupLesson && widget.groupData != null) {
//       _showGroupSelectionDialog();
//     } else {
//       currentStudents = widget.students;
//       _loadAttendance();
//     }
//   }

//   Future<void> _showGroupSelectionDialog() async {
//     final selected = await showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Выберите группу'),
//         content: const Text('Этот урок разделён на две группы. Пожалуйста, выберите, какую группу вы отмечаете:'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, '1'),
//             child: const Text('Группа 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, '2'),
//             child: const Text('Группа 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );

//     if (selected == null) {
//       // ignore: use_build_context_synchronously
//       Navigator.pop(context); // если закрыли диалог — выход
//       return;
//     }

//     setState(() {
//       selectedGroup = selected;
//       final groupList = widget.groupData!['group$selected'] as List<dynamic>? ?? [];
//       currentStudents = groupList.cast<String>();
//     });

//     _loadAttendance();
//   }

//   String _getKey() {
//     return '${widget.year}-${widget.month}-${widget.date}-${widget.lesson}';
//   }

//   Future<void> _loadAttendance() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final key = _getKey();

//       List<Map<String, dynamic>> loadedAttendance = [];

//       if (prefs.containsKey(key)) {
//         final allLoaded = (jsonDecode(prefs.getString(key)!) as List<dynamic>)
//             .map((x) => Map<String, dynamic>.from(x as Map))
//             .toList();

//         // Фильтруем только по текущим студентам (обычный урок — все, групповой — только из выбранной группы)
//         loadedAttendance = allLoaded.where((a) => currentStudents.contains(a['name'])).toList();
//       }

//       // Добавляем отсутствующих в списке студентов
//       for (var student in currentStudents) {
//         if (!loadedAttendance.any((a) => a['name'] == student)) {
//           loadedAttendance.add({
//             'name': student,
//             'present': false,
//             'absent': false,
//             'sick': false,
//             'documented': false,
//             'lateTime': null,
//           });
//         }
//       }

//       // Сортируем по порядку из общего списка студентов
//       loadedAttendance.sort((a, b) => currentStudents.indexOf(a['name']).compareTo(currentStudents.indexOf(b['name'])));

//       setState(() {
//         attendance = loadedAttendance;
//       });
//     } catch (e) {
//       debugPrint('Error loading attendance: $e');
//     }
//   }

//   Future<void> _saveAttendance() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final key = _getKey();

//       // Загружаем все существующие данные по этому уроку
//       List<Map<String, dynamic>> allAttendance = [];
//       if (prefs.containsKey(key)) {
//         allAttendance = (jsonDecode(prefs.getString(key)!) as List<dynamic>)
//             .map((x) => Map<String, dynamic>.from(x as Map))
//             .toList();
//       }

//       // Обновляем только наших студентов
//       for (var record in attendance) {
//         final index = allAttendance.indexWhere((e) => e['name'] == record['name']);
//         if (index != -1) {
//           allAttendance[index] = record;
//         } else {
//           allAttendance.add(record);
//         }
//       }

//       await prefs.setString(key, jsonEncode(allAttendance));
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//     }
//   }

//   void _toggleAttendance(int index, String status) {
//     setState(() {
//       attendance[index]['present'] = status == 'present';
//       attendance[index]['absent'] = status == 'absent';
//       attendance[index]['sick'] = status == 'sick';
//       attendance[index]['documented'] = status == 'documented';

//       if (status == 'present' || status == 'sick' || status == 'documented') {
//         attendance[index]['absent'] = false;
//       }
//       if (status == 'absent' || status == 'sick' || status == 'documented') {
//         attendance[index]['present'] = false;
//       }
//       if (status == 'present' || status == 'absent' || status == 'documented') {
//         attendance[index]['sick'] = false;
//       }
//       if (status == 'present' || status == 'absent' || status == 'sick') {
//         attendance[index]['documented'] = false;
//       }
//     });
//     _saveAttendance();
//   }

//   Future<void> _setLateTime(int index) async {
//     final TimeOfDay? selectedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) => MediaQuery(
//         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//         child: child!,
//       ),
//     );
//     if (selectedTime != null) {
//       setState(() {
//         attendance[index]['lateTime'] =
//             '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
//       });
//       _saveAttendance();
//     }
//   }

//   Future<void> _editOrRemoveLateTime(int index) async {
//     final currentTimeStr = attendance[index]['lateTime'] as String?;
//     TimeOfDay initialTime = TimeOfDay.now();
//     if (currentTimeStr != null) {
//       final parts = currentTimeStr.split(':');
//       initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
//     }

//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(AppLocalizations.of(context).editLateTimeTitle),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 final time = await showTimePicker(
//                   context: context,
//                   initialTime: initialTime,
//                   builder: (context, child) => MediaQuery(
//                     data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//                     child: child!,
//                   ),
//                 );
//                 if (time != null) {
//                   setState(() {
//                     attendance[index]['lateTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//                   });
//                   _saveAttendance();
//                 }
//               },
//               child: Text(AppLocalizations.of(context).editTimeButton),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).cancelButton)),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 attendance[index]['lateTime'] = null;
//               });
//               _saveAttendance();
//               Navigator.pop(context);
//             },
//             child: Text(AppLocalizations.of(context).removeTimeButton),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     final l10n = AppLocalizations.of(context);
//     return switch (month) {
//       1 => l10n.month01,
//       2 => l10n.month02,
//       3 => l10n.month03,
//       4 => l10n.month04,
//       5 => l10n.month05,
//       6 => l10n.month06,
//       7 => l10n.month07,
//       8 => l10n.month08,
//       9 => l10n.month09,
//       10 => l10n.month10,
//       11 => l10n.month11,
//       12 => l10n.month12,
//       _ => 'Month',
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);
//     final displayTitle = widget.displayLesson ?? widget.lesson;

//     final title = widget.isGroupLesson && selectedGroup != null
//         ? '$displayTitle — Группа $selectedGroup'
//         : displayTitle;

//     int presentCount = attendance.where((a) => a['present'] as bool).length;
//     int absentCount = attendance.where((a) => a['absent'] as bool).length;
//     int sickCount = attendance.where((a) => a['sick'] as bool).length;
//     int documentedCount = attendance.where((a) => a['documented'] as bool).length;
//     int lateCount = attendance.where((a) => a['lateTime'] != null).length;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$title - ${_getMonthName(widget.month)} ${widget.date}, ${widget.year}'),
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         actions: [
//           if (widget.isGroupLesson && selectedGroup != null)
//             IconButton(
//               icon: Icon(Icons.group, color: Colors.white),
//               onPressed: _showGroupSelectionDialog,
//             ),
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveAttendance,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue[50]!, Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: attendance.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ListView.separated(
//                   itemCount: attendance.length + 1,
//                   separatorBuilder: (context, index) => const Divider(height: 1),
//                   itemBuilder: (context, index) {
//                     if (index == attendance.length) {
//                       return Card(
//                         elevation: 6,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               _buildStat(l10n.presentLabel, presentCount, Colors.green),
//                               _buildStat(l10n.absentLabel, absentCount, Colors.red),
//                               _buildStat(l10n.sickLabel, sickCount, Colors.orange),
//                               _buildStat(l10n.documentedLabel, documentedCount, Colors.blue),
//                               _buildStat(l10n.lateLabel, lateCount, Colors.purple),
//                             ],
//                           ),
//                         ),
//                       );
//                     }

//                     final record = attendance[index];
//                     return Card(
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 record['name'],
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(record['present'] ? Icons.check_circle : Icons.circle_outlined, color: record['present'] ? Colors.green : Colors.grey),
//                               onPressed: () => _toggleAttendance(index, 'present'),
//                             ),
//                             IconButton(
//                               icon: Icon(record['absent'] ? Icons.cancel : Icons.radio_button_unchecked, color: record['absent'] ? Colors.red : Colors.grey),
//                               onPressed: () => _toggleAttendance(index, 'absent'),
//                             ),
//                             IconButton(
//                               icon: Icon(record['sick'] ? Icons.sick : Icons.sentiment_dissatisfied, color: record['sick'] ? Colors.orange : Colors.grey),
//                               onPressed: () => _toggleAttendance(index, 'sick'),
//                             ),
//                             IconButton(
//                               icon: Icon(record['documented'] ? Icons.description : Icons.note, color: record['documented'] ? Colors.blue : Colors.grey),
//                               onPressed: () => _toggleAttendance(index, 'documented'),
//                             ),
//                             record['lateTime'] == null
//                                 ? IconButton(
//                                     icon: const Icon(Icons.access_time, color: Colors.grey),
//                                     onPressed: () => _setLateTime(index),
//                                   )
//                                 : GestureDetector(
//                                     onTap: () => _editOrRemoveLateTime(index),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                       decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(20)),
//                                       child: Text(
//                                         record['lateTime'],
//                                         style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildStat(String label, int count, Color color) {
//     return Column(
//       children: [
//         Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
//         // ignore: deprecated_member_use
//         Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
//       ],
//     );
//   }
// }
// ignore_for_file: empty_catches

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