import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:norm_journal/l10n/app_localizations.dart';
import 'package:norm_journal/pages/day_schedule_page.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
// Page : Schedule Page
class SchedulePage extends StatefulWidget {
  final ScheduleRepository scheduleRepository;
  const SchedulePage({
    super.key,
    required this.scheduleRepository 
    });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',];
  late Map<String, List<String>> schedules = {};

 @override
void initState() {
  super.initState();

  schedules = {
    for (var day in days) day: []
    };
_loadFromRepository();
}

 Future<void> _loadFromRepository() async {
  final week = await widget.scheduleRepository.getScheduleForDate(DateTime.now());

  setState(() {
    for (var day in days) {
      schedules[day] = List<String>.from(week[day] ?? []);
    }
  });
}



  bool get allFilled => days.every((day) => schedules[day]!.isNotEmpty);

  Future<void> _saveAndProceed() async {
  try {
    await widget.scheduleRepository.saveNewSchedule(schedules);

    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    Logger(
      printer: PrettyPrinter(methodCount: 0),
    ).e('Error saving schedule :$e');
  }
}



@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final filledCount = days.where((d) => schedules[d]!.isNotEmpty).length;

  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.schedulePageTitle),
      backgroundColor: Colors.blueAccent,
      elevation: 10,
    ),

    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: allFilled ? _saveAndProceed : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.saveAndProceedButton),
      ),
    ),

    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configured $filledCount / ${days.length} days",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: filledCount / days.length,
          ),
          const SizedBox(height: 16),

          // 👇 ВАЖНО: GridView теперь в Expanded
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: days.map((day) {
                final filled = schedules[day]!.isNotEmpty;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DaySchedulePage(
                          day: day,
                          currentLessons: schedules[day]!,
                        ),
                      ),
                    );
                   if (result is List<String>) {
  setState(() {
    schedules[day] = result;
  });
}
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: filled ? Colors.green.shade400 : Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          filled ? Icons.check_circle : Icons.edit_calendar,
                          color: Colors.white,
                          size: 36,
                        ),
                        const Spacer(),
                        Text(
                          day.capitalize(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filled ? "Configured" : "Not configured",
                          style: const TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
}
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
