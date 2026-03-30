import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendancePage extends StatefulWidget {
  final String groupId;
  final int date;
  final int month;
  final int year;
  final String lesson;
  final String? displayLesson;
  final List<String> students;
  final bool isGroupLesson;
  final Map<String, dynamic>? groupData;
  final bool isteacher;

  const AttendancePage({
    super.key,
    required this.groupId,
    required this.date,
    required this.month,
    required this.year,
    required this.lesson,
    this.displayLesson,
    required this.students,
    this.isGroupLesson = false,
    this.groupData,
    this.isteacher = false,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> attendance = [];
  List<String> currentStudents = [];
  String? selectedGroup;

  // Путь к документу в Firebase
  String get _firestorePath => "${widget.groupId}_${_getKey()}";

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

  // --- ЛОГИКА ВЫБОРА ГРУППЫ ---

  Future<void> _showGroupSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Выберите группу', textAlign: TextAlign.center),
        content: const Text('Этот урок разделён на две группы.\nВыберите, с какой группой работаете сейчас:'),
        actions: [
          _groupButton('1', Colors.blue),
          const SizedBox(height: 8),
          _groupButton('2', Colors.purple),
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

  Widget _groupButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: () => Navigator.pop(context, label),
        child: Text('Группа $label', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _switchGroup() {
    final newGroup = selectedGroup == '1' ? '2' : '1';
    setState(() {
      selectedGroup = newGroup;
      final groupList = widget.groupData!['group$selectedGroup'] as List<dynamic>? ?? [];
      currentStudents = groupList.cast<String>();
      attendance.clear();
    });
    _loadAttendance();
  }

  // --- РАБОТА С ДАННЫМИ ---

  String _getKey() => '${widget.year}-${widget.month}-${widget.date}-${widget.lesson}';

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

      if (mounted) setState(() => attendance = loadedAttendance);
    } catch (e) {
      debugPrint('Error loading: $e');
    }
  }

  Future<void> _saveAttendance() async {
    if (widget.isteacher) return;
    try {
      final key = _getKey();
      final prefs = await SharedPreferences.getInstance();
      
      // Локально
      await prefs.setString(key, jsonEncode(attendance));

      // В облако
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(_firestorePath)
          .set({
        'lastUpdate': FieldValue.serverTimestamp(),
        'records': attendance,
        'studentsList' : widget.students
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving: $e');
    }
  }

  void _toggleAttendance(int index, String status) {
    setState(() {
      final keys = ['present', 'absent', 'sick', 'documented'];
      for (var key in keys) {
        attendance[index][key] = (key == status);
      }
    });
    _saveAttendance();
  }

  // --- ИНТЕРФЕЙС ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = widget.displayLesson ?? widget.lesson.replaceAll('lesson', 'Урок ');
    final title = widget.isGroupLesson && selectedGroup != null ? '$displayTitle — Группа $selectedGroup' : displayTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text('$title - ${_getMonthName(widget.month)} ${widget.date}'),
        backgroundColor: selectedGroup == '1' ? Colors.blueAccent : Colors.purpleAccent,
        actions: [
          if (widget.isGroupLesson && selectedGroup != null)
            IconButton(icon: const Icon(Icons.swap_horiz, size: 28), onPressed: _switchGroup),
          if (!widget.isteacher)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveAttendance),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore
        .instance
        .collection('attendance')
        .doc(_firestorePath)
        .snapshots(),
        builder: (context, snapshot) {
          // Если данные пришли из Firebase, синхронизируем их
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
           
           if(widget.isteacher){
            final List<dynamic>? remoteRecords = data['records'];

            if(remoteRecords != null){
              Future.microtask(() {
                if(mounted){
                setState(() {
                  attendance = remoteRecords.map((x) => Map<String, dynamic>.from(x)).toList();
                });
                }
              });
            }
           }
          }

          if (attendance.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendance.length + 1,
              itemBuilder: (context, index) {
                if (index == attendance.length) return _buildSummaryCard(l10n);

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
                        _buildLateWidget(index, record),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLateWidget(int index, Map<String, dynamic> record) {
    if (record['lateTime'] == null) {
      return IconButton(
        icon: const Icon(Icons.access_time),
        onPressed: widget.isteacher ? null : () => _setLateTime(index),
      );
    }
    return GestureDetector(
      onTap: widget.isteacher ? null : () => _editOrRemoveLateTime(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(20)),
        child: Text(record['lateTime'], style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    final p = attendance.where((a) => a['present'] == true).length;
    final a = attendance.where((a) => a['absent'] == true).length;
    final s = attendance.where((a) => a['sick'] == true).length;
    final d = attendance.where((a) => a['documented'] == true).length;
    final l = attendance.where((a) => a['lateTime'] != null).length;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(top: 16, bottom: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat(l10n.presentLabel, p, Colors.green),
            _stat(l10n.absentLabel, a, Colors.red),
            _stat(l10n.sickLabel, s, Colors.orange),
            _stat(l10n.documentedLabel, d, Colors.blue),
            _stat(l10n.lateLabel, l, Colors.purple),
          ],
        ),
      ),
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ (Время, Стили) ---

  Future<void> _setLateTime(int index) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() => attendance[index]['lateTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      _saveAttendance();
    }
  }

  Future<void> _editOrRemoveLateTime(int index) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Опоздание'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              setState(() => attendance[index]['lateTime'] = null);
              _saveAttendance();
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    final l10n = AppLocalizations.of(context);
    return [
      '', l10n.month01, l10n.month02, l10n.month03, l10n.month04, l10n.month05, l10n.month06,
      l10n.month07, l10n.month08, l10n.month09, l10n.month10, l10n.month11, l10n.month12
    ][month];
  }

  Widget _iconButton(bool active, IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: active ? color : Colors.grey[300]),
      onPressed: widget.isteacher ? null : onTap,
    );
  }

  Widget _stat(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        // ignore: deprecated_member_use
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
      ],
    );
  }
}