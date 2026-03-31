// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  // ------ Strings, Ints, Bools ------//

  String _getKey() => '${widget.year}-${widget.month}-${widget.date}-${widget.lesson}';

  String _getMonthName(int month) {
    final l10n = AppLocalizations.of(context);
    return [
      '', l10n.month01, l10n.month02, l10n.month03, l10n.month04, l10n.month05, l10n.month06,
      l10n.month07, l10n.month08, l10n.month09, l10n.month10, l10n.month11, l10n.month12
    ][month];
  }

   String get _firestorePath => "${widget.groupId}_${_getKey()}";

  // ---------- Futures --------//

  Future<void> _showGroupSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Group'),
        content: const Text('This lesson is split into groups.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, '1'), child: const Text('Group 1')),
          TextButton(onPressed: () => Navigator.pop(context, '2'), child: const Text('Group 2')),
        ],
      ),
    );
    if (selected != null) _switchGroup(selected);
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
      loadedAttendance.sort((a, b) => currentStudents
      .indexOf(a['name']).compareTo(currentStudents.indexOf(b['name'])));
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
      await prefs.setString(key, jsonEncode(attendance));
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

   Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel[widget.groupId];

      sheetObject.cell(CellIndex.indexByString("A1"))
      .value = TextCellValue("ФИО");

      sheetObject.cell(CellIndex.indexByString("B1"))
      .value = TextCellValue("Статус");

      sheetObject.cell(CellIndex.indexByString("D1"))
      .value = TextCellValue("дата: ${widget.date}.${widget.month}.${widget.year}");

      for (int i = 0; i < attendance.length; i++) {
        var record = attendance[i];
        String status = "Был(а)";
        if (record['absent'] == true) {
          status = "Н (Неявка)";
        } else if (record['sick'] == true) status = "Б (Болезнь)";
        else if (record['documented'] == true) status = "П (Причина)";
        if (record['lateTime'] != null) {
          status += " (Оп: ${record['lateTime']})";
        }
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = TextCellValue(record['name'].toString());
        
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(status);
      }
      var fileBytes = excel.save();
      if (fileBytes == null) return;
      final directory = await getTemporaryDirectory();
      final fileName = "Attendance_${widget.groupId}_${widget.date}_${widget.month}.xlsx";
      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles(
        [XFile(filePath)], 
        text: 'Журнал посещаемости: группа ${widget.groupId}, дата ${widget.date}.${widget.month}'
      );
    } catch (e) {
      debugPrint("Excel Export Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при создании Excel: $e")),
        );
      }
    }
  }

  // -------------Voids---------------//

  void _switchGroup(String group) {
    setState(() {
      selectedGroup = group;
      final groupList = widget.groupData!['group$group'] as List<dynamic>? ?? [];
      currentStudents = groupList.cast<String>();
      attendance.clear();
    });
    _loadAttendance();
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

  @override
  void initState() {
    super.initState();
    if (widget.isGroupLesson && widget.groupData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGroupSelectionDialog());
    } else {
      currentStudents = widget.students;
      _loadAttendance();
    }
  }

  // --------------Widgets-----------//

  Widget _statusChip(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: widget.isteacher ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey[500], fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLateBadge(int index, Map<String, dynamic> record) {
    if (record['lateTime'] == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(8)),
      child: Text(record['lateTime'], style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _lateAction(int index, Map<String, dynamic> record) {
    return IconButton(
      icon: Icon(Icons.access_time, color: record['lateTime'] != null ? Colors.purple : Colors.grey[300]),
      onPressed: widget.isteacher ? null : () => record['lateTime'] == null ? _setLateTime(index) : _editOrRemoveLateTime(index),
    );
  }

  Widget _buildSummaryPanel(AppLocalizations l10n) {
    final p = attendance.where((a) => a['present'] == true).length;
    final a = attendance.where((a) => a['absent'] == true).length;
    final s = attendance.where((a) => a['sick'] == true).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(p, "Present", Colors.green),
          _summaryItem(a, "Absent", Colors.red),
          _summaryItem(s, "Sick", Colors.orange),
        ],
      ),
    );
  }


  Widget _summaryItem(int count, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStudentCard(int index, AppLocalizations l10n) {
    final record = attendance[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue[50], radius: 18, child: Text(record['name'][0], style: const TextStyle(fontSize: 14))),
              const SizedBox(width: 12),
              Expanded(child: Text(record['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              _buildLateBadge(index, record),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusChip("P", record['present'], Colors.green, () => _toggleAttendance(index, 'present')),
              _statusChip("A", record['absent'], Colors.red, () => _toggleAttendance(index, 'absent')),
              _statusChip("S", record['sick'], Colors.orange, () => _toggleAttendance(index, 'sick')),
              _statusChip("D", record['documented'], Colors.blue, () => _toggleAttendance(index, 'documented')),
              _lateAction(index, record),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _groupTab("Group 1", selectedGroup == '1', () => _switchGroup('1')),
          _groupTab("Group 2", selectedGroup == '2', () => _switchGroup('2')),
        ],
      ),
    );
  }


  Widget _groupTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

 // ----------- BUILD -------///////  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = widget.displayLesson 
    ?? widget.lesson.replaceAll('lesson', 'Lesson ');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayTitle, 
            style: const TextStyle(
              color: Colors.black87, 
              fontSize: 18, 
              fontWeight: FontWeight.bold)
              ),
            Text('${widget.date} ${_getMonthName(widget.month)}', 
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          if (widget.isteacher)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.blueAccent),
              onPressed: exportToExcel,
            ),
          if (!widget.isteacher)
            IconButton(
              icon: const Icon(Icons.cloud_done_outlined, color: Colors.green),
              onPressed: _saveAttendance,
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore
        .instance
        .collection('attendance')
        .doc(_firestorePath)
        .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
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

          return Column(
            children: [
              if (widget.isGroupLesson && selectedGroup != null) _buildGroupSelector(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: attendance.length,
                  itemBuilder: (context, index) => _buildStudentCard(index, l10n),
                ),
              ),
              _buildSummaryPanel(l10n),
            ],
          );
        },
      ),
    );
  }
}