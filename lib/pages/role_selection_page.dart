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
  // Тот же _buildLanguagePicker, что и был
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
      backgroundColor: const Color(0xFFF0F4F8), // Более мягкий цвет фона
      appBar: AppBar(
        actions: [_buildLanguagePicker()],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Icon(Icons.auto_stories, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                l10n.whoAreYou,
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: 
                  FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.selectYourRole,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              _buildRoleCard(
                title: l10n.iAmMonitor,
                icon: Icons.person_add_alt_1_rounded,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterMonitorPage(
                    scheduleRepository: widget.scheduleRepository,
                    changeLanguage: widget.changeLanguage,
                  )),
                ),
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                title: l10n.iAmTeacher,
                icon: Icons.assignment_ind_rounded,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterTeacherPage(
                    scheduleRepository: widget.scheduleRepository,
                    changeLanguage: widget.changeLanguage,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}