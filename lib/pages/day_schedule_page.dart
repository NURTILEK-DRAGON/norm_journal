import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:norm_journal/constant_subjects.dart';

class DaySchedulePage extends StatefulWidget {
  final String day;
  final List<String> currentLessons;

  const DaySchedulePage({super.key, required this.day, required this.currentLessons});

  @override
  State<DaySchedulePage> createState() => _DaySchedulePageState();
}

class _DaySchedulePageState extends State<DaySchedulePage> {
  late List<String> lessons;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Logger _logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    lessons = List.from(widget.currentLessons);
    // Плавное появление списка при входе
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < lessons.length; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 400));
      }
    });
  }

  Future<void> _addLesson() async {
    if (lessons.length >= 10) return;
    final l10n = AppLocalizations.of(context)!;
    String? selectedSubject = ConstantSubjects.subjects.first;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _buildSubjectDialog(l10n, l10n.addLessonButton, selectedSubject),
    );

    if (newName != null && context.mounted) {
      setState(() {
        lessons.add(newName);
        _listKey.currentState?.insertItem(lessons.length - 1);
      });
    }
  }

  // Общий метод для красивого диалога выбора предмета
  Widget _buildSubjectDialog(AppLocalizations l10n, String title, String? initialValue) {
    String? currentSelected = initialValue;
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: DropdownButtonFormField<String>(
          value: currentSelected,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.book, color: Colors.blueAccent),
          ),
          items: ConstantSubjects.subjects.map((s) => 
          DropdownMenuItem(value: s, 
          child: Text(ConstantSubjects.getTranslatedSubject(s, l10n)))).toList(),
          onChanged: (v) => setDialogState(() => currentSelected = v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, currentSelected),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.addButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          '${l10n.scheduleFor} ${widget.day.capitalize()}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _onSavedButtonPressed,
            icon: const Icon(Icons.check, color: Colors.green),
            label: Text(l10n.saveButton, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: lessons.isEmpty 
              ? _buildEmptyState(l10n)
              : AnimatedList(
                  key: _listKey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  initialItemCount: 0, 
                  itemBuilder: (context, index, animation) {
                    return _buildLessonCard(index, animation, l10n);
                  },
                ),
          ),
          if (lessons.length < 10) _buildAddButton(l10n),
        ],
      ),
    );
  }

  Widget _buildLessonCard(int index, Animation<double> animation, AppLocalizations l10n) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.03), 
                blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                child: Center(
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
              ),
              title: Text(ConstantSubjects.getTranslatedSubject(lessons[index], l10n), 
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 16)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                    onPressed: () => _editLesson(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeLesson(index),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: InkWell(
        onTap: _addLesson,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(l10n.addLessonButton, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(l10n.noLessonsYet, style: TextStyle(color: Colors.grey[400], fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildRemovedItem(String lessonName, Animation<double> animation, AppLocalizations l10n) {
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[50], 
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text(ConstantSubjects.getTranslatedSubject(lessonName, l10n), 
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    ),
  );
}

  // --- ДОПОЛНИТЕЛЬНАЯ ЛОГИКА ---

 void _removeLesson(int index) {
  final removedItem = lessons[index]; 
  
  setState(() {
    lessons.removeAt(index);
  });

  _listKey.currentState?.removeItem(
    index,
    (context, animation) => _buildRemovedItem(
      removedItem, 
      animation, 
      AppLocalizations.of(context)!),
    duration: const Duration(milliseconds: 300),
  );
}

  Future<void> _editLesson(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _buildSubjectDialog(l10n, l10n.editLessonTitle, lessons[index]),
    );
    if (newName != null) setState(() => lessons[index] = newName);
  }

  Future<void> _saveLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule_${widget.day}', jsonEncode(lessons));
      // ignore: use_build_context_synchronously
      if (context.mounted) Navigator.pop(context, lessons);
    } catch (e) {
      _logger.e('Error saving: $e');
    }
  }

  void _onSavedButtonPressed() {
    _saveLessons();
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)!.savedSuccessfully,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}

extension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}