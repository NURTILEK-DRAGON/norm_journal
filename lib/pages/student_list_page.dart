// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';

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
      final loaded = prefs.getString('students') != null
          ? List<String>.from(jsonDecode(prefs.getString('students') ?? '[]'))
          : <String>[];
      
      setState(() {
        students = loaded;
      });

      for (int i = 0; i < students.length; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 400));
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
        Fluttertoast.showToast(
          msg: 'Success!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Error saving students: $e');
    }
  }

  void _addStudent(String studentName) {
    final name = studentName.trim();
    if (name.isNotEmpty) {
      setState(() {
        students.insert(0, name); 
        _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
      });
      _studentController.clear();
    }
  }

 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(l10n.createStudentListTitle, 
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildInputArea(l10n),
          Expanded(
            child: students.isEmpty 
              ? _buildEmptyState(l10n)
              : _buildStudentList(),
          ),
          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: TextField(
          controller: _studentController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.addStudentLabel,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => _addStudent(_studentController.text),
            ),
          ),
          onSubmitted: (value) => _addStudent(value),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_outlined, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          Text("No students yet", 
            style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }


  Widget _buildStudentList() {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      initialItemCount: students.length,
      itemBuilder: (context, index, animation) {
        return _buildStudentTile(students[index], index, animation);
      },
    );
  }


  Widget _buildStudentTile(String name, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              onPressed: () => _editStudent(index),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSaveButton(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: students.isNotEmpty ? _saveStudents : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: Text(l10n.saveAndProceedButton, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }


  Future<void> _editStudent(int index) async {
    final TextEditingController editController = TextEditingController(text: students[index]);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.editStudentName),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'action': 'remove'}),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'action': 'save', 'name': editController.text}),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result['action'] == 'save' && result['name'].toString().isNotEmpty) {
        setState(() => students[index] = result['name']);
      } else if (result['action'] == 'remove') {
        _removeStudentWithAnimation(index);
      }
    }
  }

  void _removeStudentWithAnimation(int index) {
    final removedName = students.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildStudentTile(removedName, index, animation),
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _studentController.dispose();
    super.dispose();
  }
}