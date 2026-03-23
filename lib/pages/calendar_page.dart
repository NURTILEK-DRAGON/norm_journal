import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:norm_journal/pages/day_lesson_page.dart';
import 'package:norm_journal/pages/schedule_page.dart';
import 'package:norm_journal/pages/student_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';


class CalendarPage extends StatefulWidget {
  final Function(Locale) changeLanguage;
  final ScheduleRepository scheduleRepository;
  final bool isTeacher;
  final List<String> teacherSubjects; 
  final String? monitorId;

  const CalendarPage({
    super.key, 
    required this.changeLanguage, 
    required this.scheduleRepository,
    this.isTeacher = false,
    this.teacherSubjects = const [],
    this.monitorId,});
  
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  late List<String> students;
  final  _logger = Logger(); 
  bool hasSchedule = false;
  Set<DateTime> scheduleChangeDays = {};



  @override
  void initState() {
    super.initState();
    _loadStudents();
    _checkHasSchedule();
    _loadScheduleChangeDays();
  }

Future<void> _loadScheduleChangeDays() async {
  final dates = await widget.scheduleRepository.getChangeDates();

  setState(() {
    scheduleChangeDays = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  });
}


Future<void> _checkHasSchedule() async {
  final result = await widget.scheduleRepository.hasAnySchedule();
  setState(() {
    hasSchedule = result;
  });
}

  Future<void> _loadStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        students = prefs.getString('students') != null
            ? List<String>.from(jsonDecode(prefs.getString('students') ?? '[]'))
            : <String>[];
      });
    } catch (e) {
      _logger.e('Error loading students: $e'); 
    }
  }

  Future<void> _previousMonth() async {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  Future<void> _nextMonth() async {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    final l10n = AppLocalizations.of(context);
    switch (month) {
      case 1: return l10n.month01;
      case 2: return l10n.month02;
      case 3: return l10n.month03;
      case 4: return l10n.month04;
      case 5: return l10n.month05;
      case 6: return l10n.month06;
      case 7: return l10n.month07;
      case 8: return l10n.month08;
      case 9: return l10n.month09;
      case 10: return l10n.month10;
      case 11: return l10n.month11;
      case 12: return l10n.month12;
      default: return 'Month';
    }
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getOffset() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    return (firstDay.weekday - 1) % 7;
  }

  Color _getDayColor(int weekday) {
    return (weekday == 6 || weekday == 7) ? Colors.red : Colors.black;
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    int days = _daysInMonth(currentMonth.year, currentMonth.month);
    int offset = _getOffset();
    final now = DateTime.now();

    List<String> weekdays = [
      l10n.weekday1,
      l10n.weekday2,
      l10n.weekday3,
      l10n.weekday4,
      l10n.weekday5,
      l10n.weekday6,
      l10n.weekday0,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getMonthName(currentMonth.month)} ${currentMonth.year}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              widget.changeLanguage(
                value == 'en' 
                ? const Locale('en') 
                : const Locale('ru'));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'ru',
                child: Text('Русский'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: _previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: _nextMonth,
          ),
        ],
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if(!widget.isTeacher)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudentListPage()),
                      ).then((_) => _loadStudents());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    child: const 
                    Text('Set Student List', 
                    style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                  onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage(
                  scheduleRepository: widget.scheduleRepository,)),
                    ).then((_) async {
                     await _checkHasSchedule();
                    _loadScheduleChangeDays();});
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,),
                    child: Text(
                    hasSchedule ? 'Change Schedule' : 'Set Schedule',
                          style: const TextStyle(color: Colors.white),
                          ),
                  ),

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.asMap().entries.map((entry) {
                final index = entry.key;
                final weekday = entry.value;
                final color = (index == 5 || index == 6) ? Colors.red : Colors.black;
                return Text(
                  weekday,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: GridView.builder(
                  key: ValueKey(currentMonth),
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: days + offset,
                  itemBuilder: (context, index) {
                    if (index < offset) {
                      return const SizedBox.shrink();
                    }
                    int day = index - offset + 1;
                    DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
                    final normalized = DateTime(date.year, date.month, date.day);
                    final isScheduleChangedDay = scheduleChangeDays.contains(normalized);
                    Color dayColor = _getDayColor(date.weekday);
                    bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DayLessonsPage(
                              scheduleRepository: widget.scheduleRepository,
                              selectedDate: date,
                              students: students,
                              isTeacher: widget.isTeacher,
                              teacherSubjects: widget.teacherSubjects,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: isScheduleChangedDay 
                        ? Colors.green[100] 
                        : isToday 
                           ? Colors.yellow[100] 
                           : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(color: dayColor, fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
