// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:norm_journal/pages/attendance_page.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';
import 'package:norm_journal/data/repository/firestore_service.dart';

class DayLessonsPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<String> students;
  final ScheduleRepository scheduleRepository;
  final bool isTeacher;
  final List<String> teacherSubjects;
  final String? groupId;

  const DayLessonsPage({
    super.key,
    required this.scheduleRepository,
    required this.selectedDate,
    required this.students,
    this.isTeacher = false,
    this.teacherSubjects = const [],
    this.groupId,
  });

  @override
  State<DayLessonsPage> createState() => _DayLessonsPageState();
}

class _DayLessonsPageState extends State<DayLessonsPage> {
  List<String> lessonNames = [];
  List<String> allDayLessons = [];
  String? currentGroupId;
  bool isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _fetchedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  // --- ЛОГИКА ОСТАЛАСЬ ПРЕЖНЕЙ ---
  Future<void> _loadLessons() async {
    final groupId = widget.groupId ?? await UserPreferences.getGroupId();
    final weekSchedule = await widget
    .scheduleRepository
    .getScheduleForDate(widget.selectedDate, groupId);
    final cloudStudents = await _firestoreService.getStudentList(groupId);
    final weekdayKey = _getWeekdayString(widget.selectedDate.weekday);
    List<String> allLessons = weekSchedule[weekdayKey] ?? [];

    setState(() {
      allDayLessons = allLessons;
      currentGroupId = groupId;
      _fetchedStudents = cloudStudents.isNotEmpty ? cloudStudents : widget.students;

      if (widget.isTeacher) {
        lessonNames = allLessons.where((lesson) => 
        widget.teacherSubjects.contains(lesson)).toList();
      } else {
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
      7: 'sunday'};
    return map[weekday] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(l10n.lessonsFor, 
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(l10n),
                const SizedBox(height: 10),
                Expanded(
                  child: lessonNames.isEmpty ? _buildEmptyState(l10n) : _buildLessonList(),
                ),
              ],
            ),
    );
  }

  // Красивый блок с датой сверху
  Widget _buildDateHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.selectedDate.day} ${_getMonthName(widget.selectedDate.month, l10n)}',
            style: const TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: Colors.blueAccent),
          ),
          Text(
            '${widget.selectedDate.year}, ${_getWeekdayLongName(widget.selectedDate.weekday, l10n)}',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey[600], 
              letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  // Список уроков
  Widget _buildLessonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: lessonNames.length,
      itemBuilder: (context, index) {
        final lessonName = lessonNames[index];
        final realLessonIndex = allDayLessons.indexOf(lessonName);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _navigateToAttendance(lessonName, realLessonIndex),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), 
                  blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  // Порядковый номер урока (как в журнале)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${realLessonIndex + 1}',
                        style: const TextStyle(
                          color: Colors.blueAccent, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lessonName,
                          style: const TextStyle(
                            fontSize: 17, 
                            fontWeight: FontWeight.w600, 
                            color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Нажмите, чтобы отметить посещаемость',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Экран "Нет уроков"
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.orange[100]),
          const SizedBox(height: 20),
          Text(
            widget.isTeacher ? "No lessons for this group today" : l10n.noLessonsToday,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18, 
              color: Colors.grey[400], 
              fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateToAttendance(String lessonName, int realIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(
          date: widget.selectedDate.day,
          month: widget.selectedDate.month,
          year: widget.selectedDate.year,
          lesson: 'lesson${realIndex + 1}',
          displayLesson: lessonName,
          students: _fetchedStudents,
          isteacher: widget.isTeacher,
          groupId: currentGroupId ?? 'unknown',
          isGroupLesson: false,
          groupData: null,
        ),
      ),
    );
  }

  String _getWeekdayLongName(int weekday, AppLocalizations l10n) {
    const names = {
      1: 'Monday', 
      2: 'Tuesday', 
      3: 'Wednesday', 
      4: 'Thursday', 
      5: 'Friday', 
      6: 'Saturday', 
      7: 'Sunday'};
    return names[weekday] ?? '';
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.month01; case 2: return l10n.month02; case 3: return l10n.month03;
      case 4: return l10n.month04; case 5: return l10n.month05; case 6: return l10n.month06;
      case 7: return l10n.month07; case 8: return l10n.month08; case 9: return l10n.month09;
      case 10: return l10n.month10; case 11: return l10n.month11; case 12: return l10n.month12;
      default: return '';
    }
  }
}