import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
class DaySchedulePage extends StatefulWidget {
  final String day;
  final List<String> currentLessons;

  const DaySchedulePage({super.key, required this.day, required this.currentLessons});

  @override
  State<DaySchedulePage> createState() => _DaySchedulePageState();
}

class _DaySchedulePageState extends State<DaySchedulePage> {
  late List<String> lessons;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Logger _logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    lessons = List.from(widget.currentLessons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < lessons.length; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 500));
      }
    });
  }

  Future<void> _addLesson() async {
    if (lessons.length >= 10) return;
    final l10n = AppLocalizations.of(context);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addLessonButton),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: l10n.addLessonButton,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.book, color: Colors.blue),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Navigator.pop(context, _controller.text);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text(l10n.addButton),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
    if (newName != null && context.mounted) {
      setState(() {

        lessons.add(newName);
        _listKey.currentState?.insertItem(
          lessons.length - 1,
          duration: const Duration(milliseconds: 500),
        );
      });
    }
  }

  Future<void> _editOrRemoveLesson(int index) async {
    if (index >= lessons.length) return;
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<Map<String, dynamic>>(
      context: context, // Исправлено: удалена опечатка "inished"
      builder: (context) => AlertDialog(
        title: Text(l10n.editLessonTitle), // Используем editLessonTitle или fallback
        content: Text('${l10n.lessonsFor} "${lessons[index]}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'action': 'edit', 'index': index}),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(l10n.editLessonButton),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {'action': 'remove', 'index': index}),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                Text(l10n.deleteButton, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
    if (result != null && context.mounted) {
      setState(() {
        if (result['action'] == 'edit') {
          _controller.text = lessons[index];
          showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.editLessonTitle),
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.addLessonButton,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.book, color: Colors.blue),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancelButton),
                ),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      Text(l10n.saveButton),
                    ],
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ).then((newName) {
            if (newName != null && context.mounted) {
              setState(() {
                lessons[index] = newName;
              });
            }
          });
        } else if (result['action'] == 'remove') {
          final removed = lessons.removeAt(index);
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
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
        }
      });
    }
  }

  Future<void> _saveLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule_${widget.day}', jsonEncode(lessons));
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, lessons);
      }
    } catch (e) {
      _logger.e('Error saving lessons for ${widget.day}: $e');
    }
  }

  void _showToast(){
    Fluttertoast.showToast(
      msg:'Lessons saved successfully',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.cyanAccent,
      textColor: Colors.white,
      fontSize: 16,
      timeInSecForIosWeb: 3,
      );
  }

  void _onSavedButtonPressed(){
    _saveLessons();
    _showToast();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.scheduleFor} ${widget.day.capitalize()}'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           Expanded(
  child: AnimatedList(
    key: _listKey,
    // безопаснее явно указывать начальную длину
    initialItemCount: lessons.length,
    itemBuilder: (BuildContext context, int index, Animation<double> animation) {
      if (index >= lessons.length) return const SizedBox.shrink();

      final  lesson = lessons[index]; 
        
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOutCirc)),
        ),
        child: FadeTransition(
          opacity: animation,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
  leading: const Icon(Icons.book, color: Colors.blue),
  title: Text(
    lesson,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  trailing: IconButton(
    icon: const Icon(Icons.edit, color: Colors.blue),
    onPressed: () => _editOrRemoveLesson(index),
  ),
),

          ),
        ),
      );
    },
  ),
),
            if (lessons.length < 10)
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addLesson,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(l10n.addLessonButton, style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _onSavedButtonPressed,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(l10n.saveLessonsButton, style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
  }