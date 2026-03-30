// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:norm_journal/pages/day_lesson_page.dart';
import 'package:norm_journal/pages/monitor_list_page.dart';
import 'package:norm_journal/pages/role_selection_page.dart';
import 'package:norm_journal/pages/schedule_page.dart';
import 'package:norm_journal/pages/student_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';

class CalendarPage extends StatefulWidget {
  final Function(Locale) changeLanguage;
  final ScheduleRepository scheduleRepository;

  const CalendarPage({
    super.key,
    required this.changeLanguage,
    required this.scheduleRepository,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  late List<String> students = [];
  final _logger = Logger();
  bool hasSchedule = false;
  Set<DateTime> scheduleChangeDays = {};
  bool _isTeacher = false;
  List<String> _teacherSubjects = [];
  String? _groupId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkHasSchedule();
    _loadScheduleChangeDays();
  }

  // --- ЛОГИКА ОСТАЛАСЬ ПРЕЖНЕЙ ---
  Future<void> _loadUserData() async {
    final isTeacher = await UserPreferences.isTeacher();
    final subjects = await UserPreferences.getTeacherSubjects();
    final group = await UserPreferences.getGroupId();
    final studentList = await _getStudentsFromPrefs();

    setState(() {
      _isTeacher = isTeacher;
      _teacherSubjects = subjects;
      _groupId = group;
      students = studentList;
      _isLoading = false;
    });
  }

  Future<List<String>> _getStudentsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? studentsRaw = prefs.getString('students');
      if (studentsRaw != null) {
        return List<String>.from(jsonDecode(studentsRaw));
      }
    } catch (e) {
      _logger.e('Error loading students: $e');
    }
    return [];
  }

  Future<void> _loadScheduleChangeDays() async {
    final dates = await widget.scheduleRepository.getChangeDates();
    setState(() {
      scheduleChangeDays = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    });
  }

  Future<void> _checkHasSchedule() async {
    final result = await widget.scheduleRepository.hasAnySchedule();
    setState(() {
      hasSchedule = result;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выход'),
        content: const Text('Уверены, что хотите выйти?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50], 
              foregroundColor: Colors.red),
            onPressed: () async {
              await UserPreferences.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => RoleSelectionPage(
                    scheduleRepository: widget.scheduleRepository)),
                  (route) => false,
                );
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  int _getOffset() => (DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1) % 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    int days = _daysInMonth(currentMonth.year, currentMonth.month);
    int offset = _getOffset();

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Очень светлый серо-голубой фон
      appBar: AppBar(
        title: Text(
          '${_getMonthName(context, currentMonth.month)} ${currentMonth.year}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(
            Icons.chevron_left, color: Colors.blueAccent), 
            onPressed: () => setState(() => currentMonth = DateTime(
              currentMonth.year, currentMonth.month - 1))),
          IconButton(icon: const Icon(
            Icons.chevron_right, color: Colors.blueAccent), 
            onPressed: () => setState(() => currentMonth = DateTime(
              currentMonth.year, currentMonth.month + 1))),
          _buildLanguagePicker(),
          IconButton(icon: const Icon(
            Icons.logout_rounded, color: Colors.redAccent), 
            onPressed: () => _showLogoutDialog(context)),
        ],
      ),
      body: Column(
        children: [
          _buildTopPanel(),
          _buildWeekdayHeader(l10n),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: days + offset,
                itemBuilder: (context, index) {
                  if (index < offset) return const SizedBox.shrink();
                  int day = index - offset + 1;
                  DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
                  return _buildCalendarDay(date, now);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isTeacher ? _buildTeacherButton() : _buildMonitorButtons(),
    );
  }

  Widget _buildTeacherButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), 
        blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.indigo, 
        child: Icon(Icons.group, color: Colors.white)),
        title: Text(_groupId == null || _groupId == "Teacher" 
        ? 'Выбрать группу' 
        : 'Группа: $_groupId'),
        subtitle: const Text('Нажмите, чтобы сменить'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MonitorsListPage(
            changeLanguage: widget.changeLanguage, 
            scheduleRepository: widget.scheduleRepository)))
            .then((_) => _loadUserData()),
      ),
    );
  }

  Widget _buildMonitorButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.person_add_alt_1,
            label: 'Students',
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const StudentListPage())).
              then((_) => _loadUserData()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.calendar_month,
            label: hasSchedule ? 'Change' : 'Set',
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SchedulePage(scheduleRepository: widget.scheduleRepository)))
              .then((_) { _checkHasSchedule(); _loadScheduleChangeDays(); }),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, 
            fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, DateTime now) {
    bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    bool isChanged = scheduleChangeDays.contains(DateTime(date.year, date.month, date.day));
    bool isWeekend = date.weekday == 6 || date.weekday == 7;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => DayLessonsPage(
        scheduleRepository: widget.scheduleRepository,
        selectedDate: date,
        students: [],
        isTeacher: _isTeacher,
        teacherSubjects: _teacherSubjects,
        groupId: _groupId,
      ))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isToday ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? null : Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: isToday ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isToday ? Colors.white : (isWeekend ? Colors.redAccent : Colors.black87),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isChanged)
              Positioned(
                bottom: 6,
                child: Container(width: 4, height: 4, decoration: BoxDecoration(color: isToday ? Colors.white : Colors.green, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader(AppLocalizations l10n) {
    List<String> weekdays = [
      l10n.weekday1, 
      l10n.weekday2, 
      l10n.weekday3, 
      l10n.weekday4, 
      l10n.weekday5, 
      l10n.weekday6, 
      l10n.weekday0];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((w) => Text(w, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12))).toList(),
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.blueAccent),
      onSelected: (val) => widget.changeLanguage(val == 'en' 
      ? const Locale('en') 
      : const Locale('ru')),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'ru', child: Text('Русский')),
      ],
    );
  }

  String _getMonthName(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context);
    switch (month) {
      case 1: return l10n.month01; case 2: return l10n.month02; case 3: return l10n.month03;
      case 4: return l10n.month04; case 5: return l10n.month05; case 6: return l10n.month06;
      case 7: return l10n.month07; case 8: return l10n.month08; case 9: return l10n.month09;
      case 10: return l10n.month10; case 11: return l10n.month11; case 12: return l10n.month12;
      default: return '';
    }
  }
}