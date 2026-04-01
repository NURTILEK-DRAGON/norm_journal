import 'package:flutter/material.dart';
import 'package:norm_journal/data/repository/schedule_repository.dart';
import 'register_monitor_page.dart';
import 'register_teacher_page.dart';
import 'package:norm_journal/l10n/app_localizations.dart';


class RoleSelectionPage extends StatefulWidget {
  final ScheduleRepository? scheduleRepository;
  final Function(Locale)? changeLanguage;

  const RoleSelectionPage({
    super.key, 
    this.scheduleRepository,
    required this.changeLanguage,});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}
  
  class _RoleSelectionPageState extends State<RoleSelectionPage> {
  
  Widget _buildLanguagePicker() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.blueAccent),
      onSelected: (val) => widget.changeLanguage!(
        val == 'en' ? const Locale('en') : const Locale('ru'),
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'ru', child: Text('Русский')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [_buildLanguagePicker()],
        backgroundColor: Colors.transparent,
        elevation: 0,),
      backgroundColor: Colors.cyan[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                l10n.whoAreYou,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectYourRole,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),

              // Кнопка Старосты
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: Text(
                  l10n.iAmMonitor,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterMonitorPage(
                        scheduleRepository: widget.scheduleRepository,
                        changeLanguage: widget.changeLanguage,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Кнопка Учителя
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.assignment_ind, color: Colors.white),
                label: Text(
                  l10n.iAmTeacher,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterTeacherPage(
                        scheduleRepository: widget.scheduleRepository,
                        changeLanguage: widget.changeLanguage,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
 }
