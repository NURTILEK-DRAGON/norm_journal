import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // 
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/pages/day_schedule_page.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'package:norm_journal/data/utils/user_preferences.dart';


class SchedulePage extends StatefulWidget {
  final ScheduleRepository scheduleRepository;

  const SchedulePage({super.key, required this.scheduleRepository});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> days = [
    'monday', 
    'tuesday', 
    'wednesday', 
    'thursday', 
    'friday', 
    'saturday'];
  Map<String, List<String>> schedules = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    schedules = {for (var day in days) day: []};
    _loadFromRepository();
  }

  String _translateDayName(String day, AppLocalizations l10n) {
  switch (day) {
    case 'monday': return l10n.day1;    // Пн
    case 'tuesday': return l10n.day2;   // Вт
    case 'wednesday': return l10n.day3; // Ср
    case 'thursday': return l10n.day4;  // Чт
    case 'friday': return l10n.day5;    // Пт
    case 'saturday': return l10n.day6;  // Сб
    default: return day;
  }
}

  Future<void> _loadFromRepository() async {
    try {
      final groupId = await UserPreferences.getGroupId();
      final week = await widget.scheduleRepository.getScheduleForDate(DateTime.now(), groupId);

      setState(() {
        for (var day in days) {
          schedules[day] = List<String>.from(week[day] ?? []);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  bool get allFilled => days.every((day) => schedules[day]!.isNotEmpty);

  Future<void> _saveAndProceed() async {
    try {
      final groupId = await UserPreferences.getGroupId();
      await widget.scheduleRepository.saveNewSchedule(groupId, schedules);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Logger().e('Error saving schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filledCount = days.where((d) => schedules[d]!.isNotEmpty).length;
    final progress = filledCount / days.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          l10n.schedulePageTitle,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(l10n),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(filledCount, progress, l10n),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) => _buildDayCard(days[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressHeader(int filledCount, double progress, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.weeklySetUp, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("$filledCount / ${days.length}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0 ? Colors.green : Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0 ? l10n.readyToSave : l10n.configureAllDays,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final list = schedules[day]!;
    final isFilled = list.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DaySchedulePage(day: day, currentLessons: list),
            ),
          );
          if (result is List<String>) {
            setState(() => schedules[day] = result);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isFilled 
              ? Colors.blueAccent.withOpacity(0.2) 
              : Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFilled ? Colors.blue[50] : Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFilled 
                  ? Icons.calendar_today 
                  : Icons.calendar_today_outlined,
                  color: isFilled 
                  ? Colors.blueAccent 
                  : Colors.grey[400],
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                _translateDayName(day, AppLocalizations.of(context)!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                isFilled ? "${list.length} lessons" : "Not set",
                style: TextStyle(color: isFilled ? Colors.blueAccent : Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: allFilled ? _saveAndProceed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.grey[300],
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          l10n.saveAndProceedButton,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}