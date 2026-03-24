import 'package:flutter/material.dart';
import 'package:norm_journal/pages/attendance_page.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';

// Page : Day Lessons Page
class DayLessonsPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<String> students;
  final ScheduleRepository scheduleRepository;
  final bool isTeacher;
  final List<String> teacherSubjects;

  const DayLessonsPage({
    super.key,
    required this.scheduleRepository,
    required this.selectedDate,
    required this.students, 
    this.isTeacher = false,
    this.teacherSubjects = const [],
  });

  @override
  State<DayLessonsPage> createState() => _DayLessonsPageState();
}

class _DayLessonsPageState extends State<DayLessonsPage> {
  List<String> lessonNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final groupId = await UserPreferences.getGroupId();
    final weekSchedule = await widget.scheduleRepository
    .getScheduleForDate(widget.selectedDate, groupId);
    final weekdayKey = _getWeekdayString(widget.selectedDate.weekday);
    List<String> allLessons = weekSchedule[weekdayKey] ?? [];

    setState(() {
      if(widget.isTeacher) {
        lessonNames = allLessons
        .where((lesson) => widget.teacherSubjects.contains(lesson))
        .toList();
      }
      else{
        lessonNames = allLessons;
      }
      isLoading = false;
    });
  }

  String _getWeekdayString(int weekday) {
    const map = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    return map[weekday] ?? '';
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1:
        return l10n.month01;
      case 2:
        return l10n.month02;
      case 3:
        return l10n.month03;
      case 4:
        return l10n.month04;
      case 5:
        return l10n.month05;
      case 6:
        return l10n.month06;
      case 7:
        return l10n.month07;
      case 8:
        return l10n.month08;
      case 9:
        return l10n.month09;
      case 10:
        return l10n.month10;
      case 11:
        return l10n.month11;
      case 12:
        return l10n.month12;
      default:
        return 'Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.lessonsFor} ${_getMonthName(widget.selectedDate.month, l10n)} '
          '${widget.selectedDate.day}, ${widget.selectedDate.year}',
        ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : lessonNames.isEmpty
                ? Center(
                    child: Text(
                      widget.isTeacher 
                      ? 'today you don\'t have lessons'
                      : l10n.noLessonsToday,
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: lessonNames.length,
                    itemBuilder: (context, index) {
                      final lesson = lessonNames[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            lesson,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing:
                              const Icon(Icons.check_circle_outline, color: Colors.blue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendancePage(
                                  date: widget.selectedDate.day,
                                  month: widget.selectedDate.month,
                                  year: widget.selectedDate.year,
                                  lesson: 'lesson${index + 1}',
                                  displayLesson: lesson,
                                  students: widget.students,
                                  isteacher: widget.isTeacher,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
