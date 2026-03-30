import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';

// Page : Student List Page
class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<String> students = [];
  final TextEditingController _studentController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Logger _logger = Logger(); 
  final FirestoreService _fireStoreService = FirestoreService();
  
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        students = prefs.getString('students') != null
            ? List<String>.from(jsonDecode(prefs.getString('students') ?? '[]'))
            : <String>[];
      });
      for (int i = 0; i < students.length; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 500));
      }
    } catch (e) {
      _logger.e('Error loading students: $e');
    }
  }

  Future<void> _saveStudents() async {
    try {
      final groupId = await UserPreferences.getGroupId();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('students', jsonEncode(students));
      await _fireStoreService.saveStudentList(groupId, students);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student list saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Error saving students: $e');
    }
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: 'Student list saved successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.cyanAccent,
      textColor: Colors.white,
      fontSize: 16,
      timeInSecForIosWeb: 3
       );
  } 

  void _onSavedButtonPressed(){
    _saveStudents();
    _showToast();
  }

  void _addStudent(String studentName) {
    if (studentName.isNotEmpty) {
      setState(() {
        students.add(studentName);
        _listKey.currentState?.insertItem(
          students.length - 1,
          duration: const Duration(milliseconds: 500),
        );
      });
      _studentController.clear();
    }
  }

  Future<void> _removeStudentFromAllAttendances(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final regex = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}-lesson\d+$');

      for (var key in allKeys) {
        if (regex.hasMatch(key)) {
          final stored = prefs.getString(key);
          if (stored != null) {
            var list = (jsonDecode(stored) as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            list.removeWhere((e) => e['name'] == name);
            await prefs.setString(key, jsonEncode(list));
          }
        }
      }
    } catch (e) {
      _logger.e('Error removing student from attendances: $e');
    }
  }

  Future<bool> _confirmDeleteStudent(String studentName) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.confirmDeleteTitle),
            content: Text(l10n.confirmDeleteMessage(studentName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.deleteButton, style: const TextStyle(color: Colors.red)),
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ) ??
        false;
  }

  Future<void> _editStudent(int index) async {
    final TextEditingController editController = TextEditingController(text: students[index]);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).editStudentName),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).addStudentLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'action': 'remove', 'index': index}),
            child: Text(AppLocalizations.of(context).removeStudentButton, style: const TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {'action': 'cancel'}),
            child: Text(AppLocalizations.of(context).cancelButton),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                Navigator.pop(context, {'action': 'save', 'name': editController.text});
              }
            },
            child: Text(AppLocalizations.of(context).saveButton),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

    if (result != null && context.mounted) {
      if (result['action'] == 'save' && result['name'] != students[index]) {
        setState(() {
          students[index] = result['name'];
        });
        await _saveStudents();
      } else if (result['action'] == 'remove') {
        final studentName = students[index];
        final confirmed = await _confirmDeleteStudent(studentName);
        if (confirmed && context.mounted) {
          final removed = students.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: FadeTransition(
                opacity: animation.drive(
                  Tween<double>(
                    begin: 1.0,
                    end: 0.0,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(removed, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              ),
            ),
            duration: const Duration(milliseconds: 600),
          );
          await _removeStudentFromAllAttendances(removed);
          await _saveStudents();
        }
      }
    }
  }

  @override
  void dispose() {
    _studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createStudentListTitle),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _studentController,
                decoration: InputDecoration(
                  labelText: l10n.addStudentLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) _addStudent(value);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_studentController.text.isNotEmpty) _addStudent(_studentController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                child: Text(l10n.addButton, style: const TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  initialItemCount: students.length,
                  itemBuilder: (context, index, animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(students[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editStudent(index),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: ElevatedButton(
                  onPressed: students.isNotEmpty ? _onSavedButtonPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                  ),
                  child: Text(l10n.saveAndProceedButton, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}